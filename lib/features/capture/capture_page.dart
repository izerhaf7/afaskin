import 'dart:async';
import 'dart:typed_data';

import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/router/app_router.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/widgets/afa_button.dart';
import 'package:afaskin/core/widgets/state_views.dart';
import 'package:afaskin/features/analysis/analysis_flow.dart';
import 'package:afaskin/features/capture/capture_services.dart';
import 'package:afaskin/features/capture/face_guidance.dart';
import 'package:afaskin/features/capture/live_camera_view.dart';
import 'package:afaskin/features/capture/photo_adjust_page.dart';
import 'package:afaskin/features/capture/photo_processing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Builds the live camera. Replaced in tests (no camera in the test VM).
typedef CameraViewBuilder = Widget Function({
  required bool active,
  required ValueChanged<Uint8List> onCaptured,
  required VoidCallback onUnavailable,
  CapturePose pose,
  double? avoidYawSign,
  ValueChanged<double?>? onYawCaptured,
});

Widget _defaultCamera({
  required bool active,
  required ValueChanged<Uint8List> onCaptured,
  required VoidCallback onUnavailable,
  CapturePose pose = CapturePose.front,
  double? avoidYawSign,
  ValueChanged<double?>? onYawCaptured,
}) => LiveCameraView(
  active: active,
  onCaptured: onCaptured,
  onUnavailable: onUnavailable,
  pose: pose,
  avoidYawSign: avoidYawSign,
  onYawCaptured: onYawCaptured,
);

/// Live camera factory; tests override it with a fake (no camera in tests).
final cameraViewBuilderProvider = Provider<CameraViewBuilder>(
  (ref) => _defaultCamera,
);

/// Resize + EXIF strip, off the UI thread. Overridable for tests.
final photoProcessorProvider = Provider<Future<Uint8List> Function(Uint8List)>(
  (ref) => preparePhotoInBackground,
);

/// Crop persegi dari layar "Atur posisi", off the UI thread.
final photoCropProvider =
    Provider<Future<Uint8List> Function(Uint8List, Rect, {int target})>(
      (ref) => cropPhotoInBackground,
    );

/// Pembaca ukuran gambar untuk layar "Atur posisi". Overridable di test.
final photoSizeProvider = Provider<Future<Size> Function(Uint8List)>(
  (ref) => decodeImageSize,
);

enum _Phase { checking, rationale, denied, camera, cameraUnavailable }

class CapturePage extends ConsumerStatefulWidget {
  const CapturePage({super.key});

  @override
  ConsumerState<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends ConsumerState<CapturePage>
    with WidgetsBindingObserver {
  _Phase _phase = _Phase.checking;
  bool _processing = false;

  /// False while the analyzing page is on top (camera stream paused).
  bool _active = true;

  /// Three-view capture: 0 = front (required), 1 and 2 = side photos
  /// (optional, the user may skip to the analysis after the front one).
  int _shot = 0;

  /// Yaw sign of the first side photo, so the second one turns the other way.
  double? _firstSideYawSign;
  double? _lastCapturedYaw;

  CapturePose get _pose => _shot == 0 ? CapturePose.front : CapturePose.side;

  void _resetShots() {
    _shot = 0;
    _firstSideYawSign = null;
    _lastCapturedYaw = null;
    ref.read(pendingSidePhotosProvider.notifier).clear();
  }

  CameraPermissionService get _permission => ref.read(cameraPermissionProvider);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_checkPermission());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Coming back from the phone's settings: the user may have enabled it.
    if (state == AppLifecycleState.resumed && _phase == _Phase.denied) {
      unawaited(_checkPermission());
    }
  }

  Future<void> _checkPermission() async {
    final s = await _permission.status();
    if (!mounted) return;
    setState(
      () => _phase = switch (s) {
        CameraPermissionState.granted => _Phase.camera,
        CameraPermissionState.permanentlyDenied => _Phase.denied,
        // Explain first, then show the system dialog.
        CameraPermissionState.denied => _Phase.rationale,
      },
    );
  }

  Future<void> _request() async {
    final s = await _permission.request();
    if (!mounted) return;
    setState(
      () => _phase = switch (s) {
        CameraPermissionState.granted => _Phase.camera,
        CameraPermissionState.permanentlyDenied => _Phase.denied,
        CameraPermissionState.denied => _Phase.rationale,
      },
    );
  }

  /// A gallery photo is used as the front view only. The user positions it
  /// first: gallery shots are often off-centre or zoomed out, which the quality
  /// gate rejects, so cropping here is what makes them usable.
  Future<void> _fromGallery() async {
    final raw = await ref.read(galleryPickerProvider).pick();
    if (raw == null || !mounted) return;
    setState(() => _processing = true);
    Uint8List prepared;
    try {
      prepared = await ref.read(photoProcessorProvider)(raw);
    } on PhotoDecodeException {
      if (mounted) {
        setState(() => _processing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.photoReadError)),
        );
      }
      return;
    }
    if (!mounted) return;
    setState(() => _processing = false);
    final cropped = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute<Uint8List>(
        builder: (_) => PhotoAdjustPage(
          bytes: prepared,
          onCrop: ref.read(photoCropProvider),
          decodeSize: ref.read(photoSizeProvider),
        ),
      ),
    );
    if (cropped == null || !mounted) return;
    _resetShots();
    // Sudah di-crop dan di-resize di layar atur posisi: jangan diproses ulang.
    await _submit(cropped, analyzeNow: true, prepared: true);
  }

  Future<void> _submit(
    Uint8List raw, {
    bool analyzeNow = false,
    bool prepared = false,
  }) async {
    setState(() => _processing = true);
    try {
      final jpeg = prepared ? raw : await ref.read(photoProcessorProvider)(raw);
      if (_shot == 0) {
        ref.read(pendingPhotoProvider.notifier).set(jpeg);
        ref.read(pendingSidePhotosProvider.notifier).clear();
      } else {
        ref.read(pendingSidePhotosProvider.notifier).add(jpeg);
        if (_shot == 1) _firstSideYawSign = _lastCapturedYaw?.sign;
      }
    } on PhotoDecodeException {
      if (mounted) {
        setState(() => _processing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.photoReadError)),
        );
      }
      return;
    }
    if (!mounted) return;
    if (!analyzeNow && _shot < 2) {
      // Next view of the three-view capture. The step header says the photo
      // was saved (a snackbar would cover the skip button).
      setState(() {
        _processing = false;
        _shot++;
      });
      return;
    }
    await _analyze();
  }

  Future<void> _analyze() async {
    setState(() {
      _processing = false;
      _active = false;
    });
    // Comes back here only for a retake (success replaces the stack).
    await context.push(AppRoutes.analyzing);
    if (mounted) {
      setState(() {
        _active = true;
        _resetShots();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.captureTitle)),
      body: SafeArea(
        child: _processing
            ? const LoadingView(message: AppStrings.processingPhoto)
            : Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Column(
                  children: [
                    if (_phase == _Phase.camera) _StepHeader(shot: _shot),
                    Expanded(child: _body()),
                    const SizedBox(height: AppSpacing.sm),
                    if (_shot == 0)
                      AfaButton.secondary(
                        label: AppStrings.pickFromGallery,
                        icon: Icons.photo_library_outlined,
                        onPressed: _fromGallery,
                      )
                    else
                      AfaButton.secondary(
                        label: AppStrings.skipSidePhotos,
                        icon: Icons.skip_next_rounded,
                        onPressed: () => unawaited(_analyze()),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _body() => switch (_phase) {
    _Phase.checking => const LoadingView(),
    _Phase.rationale => EmptyView(
      icon: Icons.photo_camera_front_outlined,
      title: AppStrings.permissionTitle,
      body: AppStrings.permissionBody,
      actionLabel: AppStrings.permissionAllow,
      onAction: _request,
    ),
    _Phase.denied => EmptyView(
      icon: Icons.no_photography_outlined,
      title: AppStrings.permissionDeniedTitle,
      body: AppStrings.permissionDeniedBody,
      actionLabel: AppStrings.openSettings,
      onAction: () => unawaited(_permission.openSettings()),
    ),
    _Phase.cameraUnavailable => const EmptyView(
      icon: Icons.no_photography_outlined,
      title: AppStrings.cameraUnavailable,
    ),
    _Phase.camera => ref.read(cameraViewBuilderProvider)(
      active: _active,
      pose: _pose,
      avoidYawSign: _shot == 2 ? _firstSideYawSign : null,
      onYawCaptured: (yaw) => _lastCapturedYaw = yaw,
      onCaptured: (raw) => unawaited(_submit(raw)),
      onUnavailable: () {
        if (mounted) setState(() => _phase = _Phase.cameraUnavailable);
      },
    ),
  };
}

/// "Foto 1 dari 3 · Tampak depan" plus a hint on the optional side photos.
class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.shot});

  final int shot;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final title = switch (shot) {
      0 => AppStrings.captureStepFront,
      1 => AppStrings.captureStepSide1,
      _ => AppStrings.captureStepSide2,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Semantics(
        liveRegion: true,
        child: Column(
          children: [
            Text(title, style: text.titleMedium, textAlign: TextAlign.center),
            if (shot > 0) ...[
              Text(
                shot == 1
                    ? AppStrings.frontPhotoSaved
                    : AppStrings.sidePhotoSaved,
                style: text.bodyMedium,
                textAlign: TextAlign.center,
              ),
              Text(
                AppStrings.captureSideHint,
                style: text.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
