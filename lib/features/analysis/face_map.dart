import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:material_ui/material_ui.dart';

/// Schematic face with the ROI boxes from the API.
///
/// ROI `bbox` values are normalized to the uploaded photo. The photo was
/// framed with the face filling the guide oval, so drawing a face silhouette
/// across the same normalized frame lines the boxes up closely enough for a
/// "where on my face" overview. No photo is kept, so none is shown.
class FaceMap extends StatelessWidget {
  const FaceMap({
    required this.rois,
    required this.highlighted,
    super.key,
    this.emphasized = const {},
  });

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
