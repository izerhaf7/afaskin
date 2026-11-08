import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/core/widgets/afa_card.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:material_ui/material_ui.dart';

/// Close-up crops of the regions that actually show a condition.
///
/// The face map answers "where", this answers "how does it look". Crops come
/// from the same photo as the map — it lives in memory only, so the strip is
/// empty for stored analyses from History.
class ProblemCloseups extends StatefulWidget {
  const ProblemCloseups({
    required this.rois,
    required this.labelsByRegion,
    super.key,
    this.photo,
    this.selected,
    this.onTapRegion,
  });

  /// Front photo of this analysis, or null when it is no longer in memory.
  final Uint8List? photo;

  final List<Roi> rois;

  /// Condition names per region, longest list first is drawn first.
  final Map<FaceRegion, List<String>> labelsByRegion;

  /// Region of the condition the user tapped (drawn with a ring).
  final FaceRegion? selected;

  final ValueChanged<FaceRegion>? onTapRegion;

  @override
  State<ProblemCloseups> createState() => _ProblemCloseupsState();
}

class _ProblemCloseupsState extends State<ProblemCloseups> {
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    unawaited(_decode());
  }

  @override
  void didUpdateWidget(ProblemCloseups old) {
    super.didUpdateWidget(old);
    if (!identical(old.photo, widget.photo)) unawaited(_decode());
  }

  Future<void> _decode() async {
    final photo = widget.photo;
    if (photo == null) return;
    final ui.FrameInfo frame;
    try {
      final codec = await ui.instantiateImageCodec(photo);
      frame = await codec.getNextFrame();
    } on Object {
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

  /// Crop rect for a region: the ROI box, squared in pixels so the thumbnail
  /// is not stretched, centred on the box.
  ///
  /// No per-region nudging: on a selfie framed by the camera guide the boxes
  /// sit on skin. An extreme close-up can push a region (e.g. the chin)
  /// against the photo edge, and no crop of a bounded image can recover skin
  /// that was never in frame.
  Rect _cropFor(Roi roi, ui.Image im) {
    final r = roi.rect;
    final sidePx = math.max(r.width * im.width, r.height * im.height) * 1.25;
    final side = sidePx < 8 ? 8.0 : sidePx;
    final c = r.center;
    final l = (c.dx * im.width - side / 2)
        .clamp(0.0, math.max(0.0, im.width - side))
        .toDouble();
    final t = (c.dy * im.height - side / 2)
        .clamp(0.0, math.max(0.0, im.height - side))
        .toDouble();
    return Rect.fromLTWH(l, t, side, side);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final regions = widget.labelsByRegion.keys.toList();
    if (regions.isEmpty) return const SizedBox.shrink();

    final im = _image;
    if (im == null) {
      return AfaCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(AppStrings.closeupNoPhoto, style: text.bodySmall),
      );
    }

    final byName = {for (final r in widget.rois) r.name: r};
    return SizedBox(
      height: 176,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: regions.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, i) {
          final region = regions[i];
          final roi = byName[region];
          if (roi == null) return const SizedBox.shrink();
          final labels = widget.labelsByRegion[region] ?? const <String>[];
          final isSelected = widget.selected == region;
          return _CloseupCard(
            image: im,
            crop: _cropFor(roi, im),
            regionLabel: AppStrings.region(region),
            conditions: labels,
            selected: isSelected,
            onTap: widget.onTapRegion == null
                ? null
                : () => widget.onTapRegion!(region),
          );
        },
      ),
    );
  }
}

class _CloseupCard extends StatelessWidget {
  const _CloseupCard({
    required this.image,
    required this.crop,
    required this.regionLabel,
    required this.conditions,
    required this.selected,
    required this.onTap,
  });

  final ui.Image image;
  final Rect crop;
  final String regionLabel;
  final List<String> conditions;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final semantics = [regionLabel, ...conditions].join(', ');
    return Semantics(
      button: onTap != null,
      label: semantics,
      child: SizedBox(
        width: 132,
        child: Material(
          color: AppColors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.cardAll,
            side: BorderSide(
              color: selected ? AppColors.danger : AppColors.outline,
              width: selected ? 2 : 1,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 112,
                  child: ExcludeSemantics(
                    child: CustomPaint(painter: _CropPainter(image, crop)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        regionLabel,
                        style: text.titleSmall?.copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        conditions.join(', '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall?.copyWith(
                          fontSize: 11,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
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

class _CropPainter extends CustomPainter {
  const _CropPainter(this.image, this.crop);

  final ui.Image image;

  /// Crop rect in image pixels.
  final Rect crop;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..filterQuality = FilterQuality.medium;
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(
        crop.left,
        crop.top,
        math.min(crop.width, image.width.toDouble()),
        math.min(crop.height, image.height.toDouble()),
      ),
      Offset.zero & size,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CropPainter old) =>
      old.image != image || old.crop != crop;
}
