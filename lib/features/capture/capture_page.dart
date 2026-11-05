import 'dart:async';
import 'dart:typed_data';

import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/router/app_router.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/widgets/afa_button.dart';
import 'package:afaskin/core/widgets/state_views.dart';
import 'package:afaskin/features/analysis/analysis_flow.dart';
import 'package:afaskin/features/capture/capture_services.dart';
import 'package:afaskin/features/capture/live_camera_view.dart';
import 'package:afaskin/features/capture/photo_processing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Builds the live camera. Replaced in tests (no camera in the test VM).
typedef CameraViewBuilder = Widget Function({
  required bool active,
  required ValueChanged<Uint8List> onCaptured,
  required VoidCallback onUnavailable,
});

Widget _defaultCamera({
  required bool active,
  required ValueChanged<Uint8List> onCaptured,
  required VoidCallback onUnavailable,
}) => LiveCameraView(
  active: active,
  onCaptured: onCaptured,
  onUnavailable: onUnavailable,
);

/// Live camera factory; tests override it with a fake (no camera in tests).
final cameraViewBuilderProvider = Provider<CameraViewBuilder>(
  (ref) => _defaultCamera,
);

/// Resize + EXIF strip, off the UI thread. Overridable for tests.
final photoProcessorProvider = Provider<Future<Uint8List> Function(Uint8List)>(
  (ref) => preparePhotoInBackground,
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

  Future<void> _fromGallery() async {
    final raw = await ref.read(galleryPickerProvider).pick();
    if (raw != null) await _submit(raw);
  }

  Future<void> _submit(Uint8List raw) async {
    setState(() => _processing = true);
    try {
      final jpeg = await ref.read(photoProcessorProvider)(raw);
      ref.read(pendingPhotoProvider.notifier).set(jpeg);
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
    setState(() {
      _processing = false;
      _active = false;
    });
    // Comes back here only for a retake (success replaces the stack).
    await context.push(AppRoutes.analyzing);
    if (mounted) setState(() => _active = true);
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
                    Expanded(child: _body()),
                    const SizedBox(height: AppSpacing.sm),
                    AfaButton.secondary(
                      label: AppStrings.pickFromGallery,
                      icon: Icons.photo_library_outlined,
                      onPressed: _fromGallery,
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
      onCaptured: (raw) => unawaited(_submit(raw)),
      onUnavailable: () {
        if (mounted) setState(() => _phase = _Phase.cameraUnavailable);
      },
    ),
  };
}
