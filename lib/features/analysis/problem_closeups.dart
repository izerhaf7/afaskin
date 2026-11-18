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
    this.sidePhotos = const [],
    this.conditions = const [],
    this.selected,
    this.onTapRegion,
  });

  /// Front photo of this analysis, or null when it is no longer in memory.
  final Uint8List? photo;

  /// Foto samping (memory only). Area yang lesinya terlihat dari samping ikut
  /// disorot dari foto samping, bukan hanya foto depan.
  final List<Uint8List> sidePhotos;

  /// Kondisi beserta lokasi lesinya, dipakai untuk memilih foto samping.
  final List<SkinCondition> conditions;

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
  static const double _cardWidth = 132;
  static const double _gap = AppSpacing.xs;
  final ScrollController _scroll = ScrollController();
  ui.Image? _image;
  final List<ui.Image> _sideImages = [];

  @override
  void initState() {
    super.initState();
    unawaited(_decode());
  }

  @override
  void didUpdateWidget(ProblemCloseups old) {
    super.didUpdateWidget(old);
    if (!identical(old.photo, widget.photo)) unawaited(_decode());
    if (old.sidePhotos.length != widget.sidePhotos.length) {
      _decodeSides();
    }
    // Dipilih dari peta wajah: geser baris close-up supaya kartunya terlihat.
    if (old.selected != widget.selected && widget.selected != null) {
      final i = widget.labelsByRegion.keys.toList().indexOf(widget.selected!);
      if (i >= 0 && _scroll.hasClients) {
        final target = math.min(
          i * (_cardWidth + _gap),
          _scroll.position.maxScrollExtent,
        );
        unawaited(
          _scroll.animateTo(
            target,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          ),
        );
      }
    }
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

  Future<void> _decodeSides() async {
    for (final im in _sideImages) {
      im.dispose();
    }
    _sideImages.clear();
    for (final jpeg in widget.sidePhotos) {
      try {
        final codec = await ui.instantiateImageCodec(jpeg);
        final frame = await codec.getNextFrame();
        if (!mounted) {
          frame.image.dispose();
          return;
        }
        _sideImages.add(frame.image);
      } on Object {
        // Foto samping yang tidak bisa dibaca dilewati.
      }
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _scroll.dispose();
    _image?.dispose();
    for (final im in _sideImages) {
      im.dispose();
    }
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

  /// Crop di sekitar kelompok lesi yang terlihat pada foto samping.
  Rect _cropAroundSpots(List<ConditionSpot> spots, ui.Image im) {
    var cx = 0.0;
    var cy = 0.0;
    for (final s in spots) {
      cx += s.x;
      cy += s.y;
    }
    cx /= spots.length;
    cy /= spots.length;
    final side = im.width * 0.30;
    final sq = side < 8 ? 8.0 : side;
    final l = (cx * im.width - sq / 2)
        .clamp(0.0, math.max(0.0, im.width - sq))
        .toDouble();
    final t = (cy * im.height - sq / 2)
        .clamp(0.0, math.max(0.0, im.height - sq))
        .toDouble();
    return Rect.fromLTWH(l, t, sq, sq);
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
    final cards = <_CardSpec>[];
    for (final region in regions) {
      final roi = byName[region];
      if (roi != null) {
        cards.add(_CardSpec(
          image: im,
          crop: _cropFor(roi, im),
          region: region,
          viewLabel: null,
        ));
      }
      // Foto samping yang lesinya berada di area ini ikut disorot.
      for (var v = 0; v < _sideImages.length; v++) {
        final spots = <ConditionSpot>[
          for (final c in widget.conditions)
            for (final sp in c.spots)
              if (sp.region == region && sp.viewIndex == v + 1) sp,
        ];
        if (spots.isEmpty) continue;
        cards.add(_CardSpec(
          image: _sideImages[v],
          crop: _cropAroundSpots(spots, _sideImages[v]),
          region: region,
          viewLabel: 'Samping ${v + 1}',
        ));
      }
    }
    return SizedBox(
      height: 176,
      child: ListView.separated(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, i) {
          final c = cards[i];
          return _CloseupCard(
            image: c.image,
            crop: c.crop,
            regionLabel: AppStrings.region(c.region),
            viewLabel: c.viewLabel,
            conditions: widget.labelsByRegion[c.region] ?? const <String>[],
            selected: widget.selected == c.region,
            onTap: widget.onTapRegion == null
                ? null
                : () => widget.onTapRegion!(c.region),
          );
        },
      ),
    );
  }
}

/// Satu kartu sorotan: foto mana yang dipotong dan area mana.
class _CardSpec {
  const _CardSpec({
    required this.image,
    required this.crop,
    required this.region,
    required this.viewLabel,
  });

  final ui.Image image;
  final Rect crop;
  final FaceRegion region;
  final String? viewLabel;
}

class _CloseupCard extends StatelessWidget {
  const _CloseupCard({
    required this.image,
    required this.crop,
    required this.regionLabel,
    required this.conditions,
    required this.selected,
    required this.onTap,
    this.viewLabel,
  });

  final ui.Image image;
  final Rect crop;
  final String regionLabel;

  /// "Samping 1" dst. Null untuk foto depan.
  final String? viewLabel;
  final List<String> conditions;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final semantics = [if (viewLabel != null) viewLabel!, regionLabel, ...conditions]
        .join(', ');
    return Semantics(
      button: onTap != null,
      label: semantics,
      child: SizedBox(
        width: _ProblemCloseupsState._cardWidth,
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
                        viewLabel == null
                            ? regionLabel
                            : '$regionLabel · $viewLabel',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
