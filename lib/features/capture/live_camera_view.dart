import 'dart:async';
import 'dart:io';

import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/features/capture/capture_services.dart';
import 'package:afaskin/features/capture/face_guidance.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:material_ui/material_ui.dart';

/// Front camera preview with an oval guide and live ML Kit framing checks.
/// ML Kit is only used for guidance here; the analysis runs on the server.
class LiveCameraView extends StatefulWidget {
  const LiveCameraView({
    required this.onCaptured,
    required this.onUnavailable,
    super.key,
    this.active = true,
    this.config = const GuidanceConfig(),
    this.pose = CapturePose.front,
    this.avoidYawSign,
    this.onYawCaptured,
  });

  /// Raw JPEG bytes from the camera (temp file already deleted).
  final ValueChanged<Uint8List> onCaptured;

  /// Front or side photo; changes the guidance rule.
  final CapturePose pose;

  /// Side photo: sign of the yaw of the side photo already taken.
  final double? avoidYawSign;

  /// Called with the head yaw (degrees) at the moment of capture.
  final ValueChanged<double?>? onYawCaptured;

  /// No camera, or it failed to start.
  final VoidCallback onUnavailable;

  /// False while another route covers this one: stops the frame stream.
  final bool active;
  final GuidanceConfig config;

  @override
  State<LiveCameraView> createState() => _LiveCameraViewState();
}

class _LiveCameraViewState extends State<LiveCameraView>
    with WidgetsBindingObserver {
  CameraController? _controller;
  late CameraDescription _camera;
  late final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(minFaceSize: 0.15),
  );

  /// Only every Nth frame goes to ML Kit, to keep the preview smooth.
  static const int _frameStride = 3;
  int _frameCount = 0;
  bool _detecting = false;
  bool _capturing = false;
  bool _streaming = false;
  GuidanceStatus _status = GuidanceStatus.noFace;

  /// Yaw of the single face in the last evaluated frame.
  double? _lastYaw;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_start());
  }

  @override
  void didUpdateWidget(LiveCameraView old) {
    super.didUpdateWidget(old);
    if (old.active != widget.active) {
      unawaited(widget.active ? _startStream() : _stopStream());
    } else if (old.pose != widget.pose ||
        old.avoidYawSign != widget.avoidYawSign) {
      // Next photo of the three-view capture: re-evaluate from scratch (the
      // stream was stopped to take the previous picture).
      _status = GuidanceStatus.noFace; // build() follows didUpdateWidget
      if (widget.active) unawaited(_startStream());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;
    if (state == AppLifecycleState.inactive) {
      // Release the camera when backgrounded (other apps may need it).
      _controller = null;
      _streaming = false;
      unawaited(c?.dispose());
      if (mounted) setState(() {});
    } else if (state == AppLifecycleState.resumed && c == null) {
      unawaited(_start());
    }
  }

  Future<void> _start() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        widget.onUnavailable();
        return;
      }
      _camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        _camera,
        // 1920x1080: skin patches are only ~15% of the face width, so 720p
        // left lesions blurry (on-device diagnosis, Nov 2026).
        ResolutionPreset.veryHigh,
        enableAudio: false,
        imageFormatGroup: Platform.isIOS
            ? ImageFormatGroup.bgra8888
            : ImageFormatGroup.nv21,
      );
      await controller.initialize();
      await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
      if (widget.active) await _startStream();
    } on CameraException catch (e) {
      debugPrint('Camera failed: ${e.code} ${e.description}');
      widget.onUnavailable();
    }
  }

  Future<void> _startStream() async {
    final c = _controller;
    if (c == null || _streaming || !c.value.isInitialized) return;
    _streaming = true;
    await c.startImageStream(_onFrame);
  }

  Future<void> _stopStream() async {
    final c = _controller;
    if (c == null || !_streaming) return;
    _streaming = false;
    await c.stopImageStream();
  }

  Future<void> _onFrame(CameraImage image) async {
    if (_detecting || _capturing) return;
    if (++_frameCount % _frameStride != 0) return;
    _detecting = true;
    try {
      final status = await _evaluate(image);
      if (status != null && mounted && status != _status) {
        setState(() => _status = status);
      }
    } on Object catch (e) {
      debugPrint('Face detection error: $e');
    } finally {
      _detecting = false;
    }
  }

  Future<GuidanceStatus?> _evaluate(CameraImage image) async {
    final camera = _camera;
    final rotation = _rotation(camera);
    if (rotation == null || image.planes.isEmpty) return null;

    final plane = image.planes.first;
    final isIOS = Platform.isIOS;
    final luminance = isIOS
        ? meanLumaBgra(
            plane.bytes,
            width: image.width,
            height: image.height,
            bytesPerRow: plane.bytesPerRow,
          )
        : meanLuma(
            plane.bytes,
            width: image.width,
            height: image.height,
            bytesPerRow: plane.bytesPerRow,
          );

    // ML Kit accepts single-plane NV21 (Android) or BGRA8888 (iOS).
    final format = switch (image.format.group) {
      ImageFormatGroup.nv21 => InputImageFormat.nv21,
      ImageFormatGroup.bgra8888 => InputImageFormat.bgra8888,
      _ => null,
    };
    if (format == null || image.planes.length != 1) return null;

    final faces = await _detector.processImage(
      InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: plane.bytesPerRow,
        ),
      ),
    );

    // ML Kit reports boxes in the upright image; for 90/270 the axes swap.
    final swapped =
        rotation == InputImageRotation.rotation90deg ||
        rotation == InputImageRotation.rotation270deg;
    final w = (swapped ? image.height : image.width).toDouble();
    final h = (swapped ? image.width : image.height).toDouble();
    final mirror = camera.lensDirection == CameraLensDirection.front;
    _lastYaw = faces.length == 1 ? faces.single.headEulerAngleY : null;

    return evaluateGuidance(
      luminance: luminance,
      config: widget.config,
      pose: widget.pose,
      avoidYawSign: widget.avoidYawSign,
      faces: [
        for (final f in faces)
          FaceObservation(
            box: normalizeFaceBox(
              f.boundingBox,
              uprightWidth: w,
              uprightHeight: h,
              mirror: mirror,
            ),
            yaw: f.headEulerAngleY,
            pitch: f.headEulerAngleX,
          ),
      ],
    );
  }

  /// Rotation ML Kit needs to read the frame upright (portrait-locked UI).
  InputImageRotation? _rotation(CameraDescription camera) {
    final sensor = camera.sensorOrientation;
    if (Platform.isIOS) return InputImageRotationValue.fromRawValue(sensor);
    // Device is locked to portraitUp, so device rotation compensation is 0.
    return InputImageRotationValue.fromRawValue(sensor % 360);
  }

  Future<void> _capture() async {
    final c = _controller;
    if (c == null || _capturing || !_status.isReady) return;
    setState(() => _capturing = true);
    try {
      // Some Android devices fail to take a picture while streaming.
      await _stopStream();
      final yaw = _lastYaw;
      final file = await c.takePicture();
      final bytes = await file.readAsBytes();
      await deleteQuietly(file.path);
      widget.onYawCaptured?.call(yaw);
      widget.onCaptured(bytes);
    } on CameraException catch (e) {
      debugPrint('Capture failed: ${e.code}');
      if (widget.active) await _startStream();
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_controller?.dispose());
    unawaited(_detector.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    final ready = _status.isReady;
    return Column(
      children: [
        Expanded(
          child: Center(
            child: c == null || !c.value.isInitialized
                ? const CircularProgressIndicator()
                : ClipRRect(
                    borderRadius: AppRadius.cardAll,
                    child: AspectRatio(
                      // Controller aspect is landscape (w/h); UI is portrait.
                      aspectRatio: 1 / c.value.aspectRatio,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CameraPreview(c),
                          CustomPaint(
                            painter: GuideOvalPainter(
                              oval: widget.config.oval,
                              ready: ready,
                            ),
                          ),
                          Positioned(
                            left: AppSpacing.md,
                            right: AppSpacing.md,
                            top: AppSpacing.md,
                            child: GuidanceBanner(status: _status),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ShutterButton(
          enabled: ready && !_capturing,
          busy: _capturing,
          onPressed: _capture,
        ),
      ],
    );
  }
}

/// Status pill on top of the preview. A live region, so screen readers
/// announce each new instruction.
class GuidanceBanner extends StatelessWidget {
  const GuidanceBanner({required this.status, super.key});

  final GuidanceStatus status;

  @override
  Widget build(BuildContext context) {
    final ready = status.isReady;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.pillAll,
          boxShadow: const [],
          border: Border.all(
            color: ready ? AppColors.positive : AppColors.outline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              ready ? Icons.check_circle_rounded : Icons.info_outline_rounded,
              size: 20,
              color: ready ? AppColors.positive : AppColors.ink,
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                status.message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: ready ? AppColors.positive : AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dims everything outside the oval and strokes the oval (sage while
/// adjusting, positive when ready).
class GuideOvalPainter extends CustomPainter {
  GuideOvalPainter({required this.oval, required this.ready});

  final Rect oval;
  final bool ready;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromLTWH(
      oval.left * size.width,
      oval.top * size.height,
      oval.width * size.width,
      oval.height * size.height,
    );
    final scrim = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addOval(r);
    canvas
      ..drawPath(scrim, Paint()..color = AppColors.scrim)
      ..drawOval(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = ready ? AppColors.positive : AppColors.sage,
      );
  }

  @override
  bool shouldRepaint(GuideOvalPainter old) =>
      old.ready != ready || old.oval != oval;
}

/// Round shutter: ink fill with a white ring; outline when disabled.
class ShutterButton extends StatelessWidget {
  const ShutterButton({
    required this.enabled,
    required this.onPressed,
    super.key,
    this.busy = false,
  });

  final bool enabled;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: AppStrings.shutter,
      hint: enabled ? null : AppStrings.shutterDisabledHint,
      child: ExcludeSemantics(
        child: Material(
          shape: const CircleBorder(),
          color: enabled ? AppColors.ink : AppColors.outline,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: enabled ? onPressed : null,
            child: Container(
              width: 76,
              height: 76,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 4),
              ),
              child: busy
                  ? const SizedBox.square(
                      dimension: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: AppColors.white,
                      ),
                    )
                  : Icon(
                      Icons.photo_camera_rounded,
                      size: 32,
                      color: enabled
                          ? AppColors.white
                          : AppColors.disabledForeground,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
