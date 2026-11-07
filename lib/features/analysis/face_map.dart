import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:material_ui/material_ui.dart';

/// Face map with the ROI boxes of the analysis.
///
/// With [photo] (only right after an analysis; the photo lives in memory and
/// is never saved) the boxes are drawn on the user's own photo, cropped around
/// the face. Without it (history) a schematic face is drawn: ROI `bbox` values
/// are normalized to the photo, which was framed with the face filling the
/// guide oval, so the silhouette lines up closely enough.
class FaceMap extends StatelessWidget {
  const FaceMap({
    required this.rois,
    required this.highlighted,
    super.key,
    this.emphasized = const {},
    this.photo,
  });

  /// Front photo (JPEG) of this analysis, or null.
  final Uint8List? photo;

  final List<Roi> rois;

  /// Regions with any detected condition.
  final Set<FaceRegion> highlighted;

  /// Regions of the condition the user tapped (drawn stronger).
  final Set<FaceRegion> emphasized;

  @override
  Widget build(BuildContext context) {
    final labels = [
      for (final r in rois)
        if (highlighted.contains(r.name)) AppStrings.region(r.name),
    ];
    final photo = this.photo;
    if (photo != null) {
      return Semantics(
        image: true,
        label: '${AppStrings.faceMapHeading}: ${labels.join(', ')}',
        child: _PhotoFaceMap(
          jpeg: photo,
          rois: rois,
          highlighted: highlighted,
          emphasized: emphasized,
        ),
      );
    }
    return Semantics(
      image: true,
      label: '${AppStrings.faceMapHeading}: ${labels.join(', ')}',
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: CustomPaint(
          painter: FaceMapPainter(
            rois: rois,
            highlighted: highlighted,
            emphasized: emphasized,
          ),
        ),
      ),
    );
  }
}

class FaceMapPainter extends CustomPainter {
  FaceMapPainter({
    required this.rois,
    required this.highlighted,
    required this.emphasized,
  });

  final List<Roi> rois;
  final Set<FaceRegion> highlighted;
  final Set<FaceRegion> emphasized;

  @override
  void paint(Canvas canvas, Size size) {
    Rect n(double l, double t, double r, double b) => Rect.fromLTRB(
      l * size.width,
      t * size.height,
      r * size.width,
      b * size.height,
    );

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = AppColors.sage;

    // Head and simple features.
    canvas
      ..drawOval(n(0.14, 0.04, 0.86, 0.96), Paint()..color = AppColors.white)
      ..drawOval(n(0.14, 0.04, 0.86, 0.96), line)
      ..drawArc(n(0.28, 0.33, 0.42, 0.39), 3.6, 2.2, false, line)
      ..drawArc(n(0.58, 0.33, 0.72, 0.39), 3.6, 2.2, false, line)
      ..drawLine(
        Offset(0.5 * size.width, 0.42 * size.height),
        Offset(0.47 * size.width, 0.56 * size.height),
        line,
      )
      ..drawArc(n(0.38, 0.62, 0.62, 0.72), 0.3, 2.5, false, line);

    for (final roi in rois) {
      if (!highlighted.contains(roi.name)) continue;
      final strong = emphasized.contains(roi.name);
      final r = Rect.fromLTWH(
        roi.rect.left * size.width,
        roi.rect.top * size.height,
        roi.rect.width * size.width,
        roi.rect.height * size.height,
      );
      final rr = RRect.fromRectAndRadius(r, const Radius.circular(10));
      canvas
        ..drawRRect(
          rr,
          Paint()
            ..color = (strong ? AppColors.danger : AppColors.caution)
                .withValues(alpha: strong ? 0.22 : 0.12),
        )
        ..drawRRect(
          rr,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = strong ? 2.5 : 1.5
            ..color = strong ? AppColors.danger : AppColors.caution,
        );
    }
  }

  @override
  bool shouldRepaint(FaceMapPainter old) =>
      old.rois != rois ||
      old.highlighted != highlighted ||
      old.emphasized != emphasized;
}

/// ROI boxes on the user's photo, cropped to the face (union of ROIs + margin).
class _PhotoFaceMap extends StatefulWidget {
  const _PhotoFaceMap({
    required this.jpeg,
    required this.rois,
    required this.highlighted,
    required this.emphasized,
  });

  final Uint8List jpeg;
  final List<Roi> rois;
  final Set<FaceRegion> highlighted;
  final Set<FaceRegion> emphasized;

  @override
  State<_PhotoFaceMap> createState() => _PhotoFaceMapState();
}

class _PhotoFaceMapState extends State<_PhotoFaceMap> {
  ui.Image? _image;

  /// Photo could not be decoded: fall back to the schematic face.
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_decode());
  }

  @override
  void didUpdateWidget(_PhotoFaceMap old) {
    super.didUpdateWidget(old);
    if (!identical(old.jpeg, widget.jpeg)) unawaited(_decode());
  }

  Future<void> _decode() async {
    final ui.FrameInfo frame;
    try {
      final codec = await ui.instantiateImageCodec(widget.jpeg);
      frame = await codec.getNextFrame();
    } on Object {
      if (mounted) setState(() => _failed = true);
      return;
    }
    if (!mounted) {
      frame.image.dispose();
      return;
    }
    setState(() {
      _image?.dispose();
      _image = frame.image;
    });
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  /// Normalized crop: all ROIs plus 45% margin, clamped to the photo.
  Rect _crop(ui.Image im) {
    if (widget.rois.isEmpty) return const Rect.fromLTWH(0, 0, 1, 1);
    var u = widget.rois.first.rect;
    for (final r in widget.rois.skip(1)) {
      u = u.expandToInclude(r.rect);
    }
    // Square-ish in pixels so the face is not squeezed.
    final wPx = u.width * im.width;
    final hPx = u.height * im.height;
    final side = math.max(wPx, hPx) * 1.45;
    final c = u.center;
    final l = (c.dx * im.width - side / 2).clamp(0, im.width - 1).toDouble();
    final t = (c.dy * im.height - side / 2).clamp(0, im.height - 1).toDouble();
    final r = math.min(l + side, im.width.toDouble());
    final b = math.min(t + side * 1.1, im.height.toDouble());
    return Rect.fromLTRB(l / im.width, t / im.height, r / im.width, b / im.height);
  }

  @override
  Widget build(BuildContext context) {
    final im = _image;
    if (_failed) {
      return AspectRatio(
        aspectRatio: 3 / 4,
        child: CustomPaint(
          painter: FaceMapPainter(
            rois: widget.rois,
            highlighted: widget.highlighted,
            emphasized: widget.emphasized,
          ),
        ),
      );
    }
    if (im == null) {
      return const AspectRatio(aspectRatio: 3 / 4, child: Center(child: CircularProgressIndicator()));
    }
    final crop = _crop(im);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: (crop.width * im.width) / (crop.height * im.height),
        child: CustomPaint(
          painter: _PhotoMapPainter(
            image: im,
            crop: crop,
            rois: widget.rois,
            highlighted: widget.highlighted,
            emphasized: widget.emphasized,
          ),
        ),
      ),
    );
  }
}

class _PhotoMapPainter extends CustomPainter {
  _PhotoMapPainter({
    required this.image,
    required this.crop,
    required this.rois,
    required this.highlighted,
    required this.emphasized,
  });

  final ui.Image image;
  final Rect crop;
  final List<Roi> rois;
  final Set<FaceRegion> highlighted;
  final Set<FaceRegion> emphasized;

  @override
  void paint(Canvas canvas, Size size) {
    final src = Rect.fromLTRB(
      crop.left * image.width,
      crop.top * image.height,
      crop.right * image.width,
      crop.bottom * image.height,
    );
    canvas.drawImageRect(image, src, Offset.zero & size, Paint()..filterQuality = FilterQuality.medium);
    Rect toView(Rect r) => Rect.fromLTRB(
      (r.left - crop.left) / crop.width * size.width,
      (r.top - crop.top) / crop.height * size.height,
      (r.right - crop.left) / crop.width * size.width,
      (r.bottom - crop.top) / crop.height * size.height,
    );
    for (final roi in rois) {
      if (!highlighted.contains(roi.name)) continue;
      final strong = emphasized.contains(roi.name);
      final rr = RRect.fromRectAndRadius(toView(roi.rect), const Radius.circular(10));
      final color = strong ? AppColors.danger : AppColors.caution;
      canvas
        ..drawRRect(rr, Paint()..color = color.withValues(alpha: strong ? 0.25 : 0.12))
        ..drawRRect(
          rr,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = strong ? 3 : 2
            ..color = color,
        );
    }
  }

  @override
  bool shouldRepaint(_PhotoMapPainter old) =>
      old.image != image ||
      old.crop != crop ||
      old.rois != rois ||
      old.highlighted != highlighted ||
      old.emphasized != emphasized;
}
