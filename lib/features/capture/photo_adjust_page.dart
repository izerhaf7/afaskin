import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Offset, Rect;

import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/widgets/afa_button.dart';
import 'package:afaskin/features/capture/crop_geometry.dart';
import 'package:material_ui/material_ui.dart';

/// Layar "Atur posisi": foto dari galeri tidak langsung dianalisis, tapi
/// diposisikan dulu. Pengguna menggeser/mencubit foto di dalam jendela persegi,
/// lalu yang dikirim ke model hanya bagian di dalam jendela.
///
/// Ini menyelesaikan penyebab kegagalan paling sering pada foto galeri: wajah
/// berada di pinggir atau terlalu kecil di bingkai, sehingga quality gate
/// menolaknya (`no_face` / `face_too_small` / `face_covered`).
class PhotoAdjustPage extends StatefulWidget {
  const PhotoAdjustPage({
    required this.bytes,
    required this.onCrop,
    this.decodeSize = decodeImageSize,
    super.key,
  });

  /// Foto mentah dari galeri.
  final Uint8List bytes;

  /// Dipisah agar bisa diganti di test.
  final Future<Uint8List> Function(Uint8List, Rect, {int target}) onCrop;

  /// Pembaca ukuran gambar; dipisah supaya test tidak perlu decode gambar asli.
  final Future<Size> Function(Uint8List) decodeSize;

  @override
  State<PhotoAdjustPage> createState() => _PhotoAdjustPageState();
}

class _PhotoAdjustPageState extends State<PhotoAdjustPage> {
  /// Sisi jendela crop di layar.
  static const double _viewport = 320;

  ImageProvider? _provider;
  Size? _imageSize;
  double _zoom = kMinCropZoom;
  Offset _pan = Offset.zero;
  bool _busy = false;
  String? _error;

  // Gestur.
  double _startZoom = 1;
  Offset _startFocal = Offset.zero;
  Offset _panAtFocal = Offset.zero;

  @override
  void initState() {
    super.initState();
    _provider = MemoryImage(widget.bytes);
    unawaited(_loadSize());
  }

  /// Ukuran gambar setelah orientasi EXIF, sama dengan yang dipakai saat crop.
  Future<void> _loadSize() async {
    try {
      final size = await widget.decodeSize(widget.bytes);
      if (!mounted) return;
      setState(() => _imageSize = size);
    } on Object {
      if (mounted) setState(() => _error = AppStrings.photoReadError);
    }
  }

  CropView get _view => CropView(
    imageWidth: _imageSize?.width ?? 1,
    imageHeight: _imageSize?.height ?? 1,
    viewport: _viewport,
    zoom: _zoom,
    pan: _pan,
  );

  void _onScaleStart(ScaleStartDetails d) {
    _startZoom = _zoom;
    _startFocal = d.localFocalPoint;
    _panAtFocal = _pan;
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    final next = (_startZoom * d.scale).clamp(kMinCropZoom, kMaxCropZoom);
    // Pertahankan titik di bawah jari tetap di tempat saat memperbesar.
    final view = _view.copyWith(zoom: next);
    final scaleRatio = next / _startZoom;
    final focalShift = (d.localFocalPoint - _startFocal) * scaleRatio;
    final centred = _panAtFocal * scaleRatio + focalShift;
    setState(() {
      _zoom = next;
      _pan = view.clampPan(centred);
    });
  }

  void _reset() => setState(() {
    _zoom = kMinCropZoom;
    _pan = Offset.zero;
  });

  Future<void> _use() async {
    final size = _imageSize;
    if (size == null || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final rect = _view.visibleRect;
      // Sisi keluaran mengikuti sisi terpendek crop, dibatasi 1200 px.
      final target = math.min(1200, rect.shortestSide.round()).clamp(320, 1200);
      final out = await widget.onCrop(widget.bytes, rect, target: target);
      if (!mounted) return;
      Navigator.of(context).pop(out);
    } on Object {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = AppStrings.adjustCropError;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final ready = _imageSize != null;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.adjustTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.adjustBody,
                style: text.bodyMedium?.copyWith(color: AppColors.inkMuted),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: Center(
                  child: ready
                      ? _CropWindow(
                          viewport: _viewport,
                          provider: _provider!,
                          view: _view,
                          onScaleStart: _onScaleStart,
                          onScaleUpdate: _onScaleUpdate,
                        )
                      // Gagal decode: jangan biarkan spinner berputar selamanya.
                      // Penanda diam (bukan spinner beranimasi) supaya layar
                      // tidak berkedip saat ukuran gambar sedang dibaca.
                      : Icon(
                          _error != null
                              ? Icons.broken_image_outlined
                              : Icons.image_outlined,
                          size: 64,
                          color: AppColors.inkMuted,
                        ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _error!,
                  style: text.bodyMedium?.copyWith(color: AppColors.danger),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              AfaButton(
                label: AppStrings.adjustUse,
                icon: Icons.check_rounded,
                loading: _busy,
                onPressed: ready && !_busy ? () => unawaited(_use()) : null,
              ),
              const SizedBox(height: AppSpacing.xs),
              AfaButton.secondary(
                label: AppStrings.adjustReset,
                icon: Icons.restart_alt_rounded,
                onPressed: ready && !_busy ? _reset : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Jendela kotak dengan foto di dalamnya, plus sudut penanda.
class _CropWindow extends StatelessWidget {
  const _CropWindow({
    required this.viewport,
    required this.provider,
    required this.view,
    required this.onScaleStart,
    required this.onScaleUpdate,
  });

  final double viewport;
  final ImageProvider provider;
  final CropView view;
  final GestureScaleStartCallback onScaleStart;
  final GestureScaleUpdateCallback onScaleUpdate;

  @override
  Widget build(BuildContext context) {
    final size = view.drawnSize;
    final tl = view.topLeft;
    return SizedBox(
      width: viewport,
      height: viewport,
      child: ClipRRect(
        borderRadius: AppRadius.cardAll,
        child: GestureDetector(
          onScaleStart: onScaleStart,
          onScaleUpdate: onScaleUpdate,
          child: ColoredBox(
            color: AppColors.ink,
            child: Stack(
              children: [
                Positioned(
                  left: tl.dx,
                  top: tl.dy,
                  width: size.dx,
                  height: size.dy,
                  child: Image(image: provider, fit: BoxFit.fill),
                ),
                // Garis bantu: bukan bagian gambar, hanya panduan visual.
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(painter: _ThirdsPainter()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Garis sepertiga + bingkai tipis, memakai warna tema.
class _ThirdsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    for (var i = 1; i < 3; i++) {
      final d = size.width * i / 3;
      canvas
        ..drawLine(Offset(d, 0), Offset(d, size.height), p)
        ..drawLine(Offset(0, d), Offset(size.width, d), p);
    }
    final border = Paint()
      ..color = AppColors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(AppRadius.card),
      ),
      border,
    );
  }

  @override
  bool shouldRepaint(_ThirdsPainter oldDelegate) => false;
}

/// Ukuran gambar setelah orientasi EXIF, dipakai untuk memetakan crop.
Future<Size> decodeImageSize(Uint8List bytes) async {
  final image = await decodeImageFromList(bytes);
  final size = Size(image.width.toDouble(), image.height.toDouble());
  image.dispose();
  return size;
}
