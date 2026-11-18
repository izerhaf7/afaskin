import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:material_ui/material_ui.dart';

/// Peta wajah yang memetakan **lesi**, bukan pembagian wajah yang kasar.
///
/// Tiap kondisi digambar sebagai kotak di lokasi patch yang
/// benar-benar membawa bukti, jadi yang terlihat adalah area yang bermasalah.
/// Kotak wilayah (forehead/cheek/chin/…) sengaja tidak digambar lagi.
///
/// Dengan [photo] (hanya tepat setelah analisis; foto hidup di memori dan tidak
/// pernah disimpan) kotak lesi dilukis di atas foto pengguna. Tanpa foto,
/// digambar di atas siluet wajah skematik dengan asumsi wajah memenuhi bingkai
/// panduan — sama seperti saat memotret.

/// Kondisi pada titik [p] (dinormalisasi 0-1 terhadap foto), atau null kalau
/// di luar semua kotak lesi.
SkinConditionLabel? hitTestSpot(List<ConditionSpot> spots, Offset p) {
  // Kotak lesi terkecil yang memuat titik menang, supaya kotak besar tidak
  // menelan kotak kecil yang bertumpuk.
  SkinConditionLabel? best;
  var bestArea = double.infinity;
  for (final s in spots) {
    final half = math.max(s.size, 0.03) / 2;
    if ((p.dx - s.x).abs() <= half && (p.dy - s.y).abs() <= half) {
      final area = s.size * s.size;
      if (area < bestArea) {
        bestArea = area;
        best = s.label;
      }
    }
  }
  return best;
}

class FaceMap extends StatelessWidget {
  const FaceMap({
    required this.spots,
    super.key,
    this.photo,
    this.emphasizedLabel,
    this.onTapCondition,
  });

  /// Foto depan (JPEG) dari analisis ini, atau null.
  final Uint8List? photo;

  /// Lokasi + kondisi lesi yang terdeteksi.
  final List<ConditionSpot> spots;

  /// Kondisi yang sedang disorot (dari kartu lesi atau ketukan di peta).
  final SkinConditionLabel? emphasizedLabel;

  /// Dipanggil saat kotak lesi diketuk. Null = peta tidak bisa diketuk.
  final ValueChanged<SkinConditionLabel>? onTapCondition;

  @override
  Widget build(BuildContext context) {
    final labels = [
      for (final c in {for (final s in spots) s.label}) AppStrings.condition(c),
    ];
    final photo = this.photo;
    if (photo != null) {
      return Semantics(
        image: true,
        label: '${AppStrings.faceMapHeading}: ${labels.join(', ')}',
        child: _PhotoFaceMap(
          jpeg: photo,
          spots: spots,
          emphasizedLabel: emphasizedLabel,
          onTapCondition: onTapCondition,
        ),
      );
    }
    return Semantics(
      image: true,
      label: '${AppStrings.faceMapHeading}: ${labels.join(', ')}',
      // LayoutBuilder HARUS di dalam AspectRatio: di luar, tingginya tak
      // terbatas, sehingga pembagi tinggi menjadi tak hingga dan setiap ketukan
      // dianggap di luar semua kotak lesi.
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: LayoutBuilder(
          builder: (context, box) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: onTapCondition == null
                ? null
                : (d) => _tap(
                    spots,
                    onTapCondition!,
                    Offset(
                      d.localPosition.dx / box.maxWidth,
                      d.localPosition.dy / box.maxHeight,
                    ),
                  ),
            child: CustomPaint(
              painter: _SchematicPainter(
                spots: spots,
                emphasizedLabel: emphasizedLabel,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void _tap(
  List<ConditionSpot> spots,
  ValueChanged<SkinConditionLabel> onTap,
  Offset p,
) {
  final label = hitTestSpot(spots, p);
  if (label != null) onTap(label);
}

/// Kotak lesi: isi tipis + garis tegas, lebih kuat saat kondisinya disorot.
///
/// Garis diberi halo putih tipis di luarnya. Tanpa halo, kotak berwarna gelap
/// (mis. `Blackhead` cokelat gelap) menghilang di atas kulit gelap atau bayangan.
void _paintSpotBox(Canvas canvas, Rect box, Color color, bool strong) {
  final rr = RRect.fromRectAndRadius(box, const Radius.circular(3));
  canvas
    ..drawRRect(
      rr,
      Paint()..color = color.withValues(alpha: strong ? 0.22 : 0.10),
    )
    ..drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strong ? 3.6 : 3.0
        ..color = AppColors.white.withValues(alpha: 0.70),
    )
    ..drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strong ? 2.2 : 1.7
        ..color = color.withValues(alpha: strong ? 1.0 : 0.95),
    );
}

class _SchematicPainter extends CustomPainter {
  _SchematicPainter({
    required this.spots,
    required this.emphasizedLabel,
  });

  final List<ConditionSpot> spots;
  final SkinConditionLabel? emphasizedLabel;

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

    // Siluet wajah sebagai pembanding lokasi lesi.
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

    for (final s in spots) {
      final half = math.max(s.size / 2, 0.03);
      final box = Rect.fromLTRB(
        (s.x - half) * size.width,
        (s.y - half) * size.height,
        (s.x + half) * size.width,
        (s.y + half) * size.height,
      );
      final color =
          AppColors.conditionColor(s.label.name);
      _paintSpotBox(canvas, box, color, emphasizedLabel == s.label);
    }
  }

  @override
  bool shouldRepaint(_SchematicPainter old) =>
      old.spots != spots || old.emphasizedLabel != emphasizedLabel;
}

/// Kotak lesi di atas foto pengguna, dipangkas mengelilingi lesi.
class _PhotoFaceMap extends StatefulWidget {
  const _PhotoFaceMap({
    required this.jpeg,
    required this.spots,
    required this.emphasizedLabel,
    required this.onTapCondition,
  });

  final Uint8List jpeg;
  final List<ConditionSpot> spots;
  final SkinConditionLabel? emphasizedLabel;
  final ValueChanged<SkinConditionLabel>? onTapCondition;

  @override
  State<_PhotoFaceMap> createState() => _PhotoFaceMapState();
}

class _PhotoFaceMapState extends State<_PhotoFaceMap> {
  ui.Image? _image;

  /// Foto tidak bisa dibaca: kembali ke siluet skematik.
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

  /// Pangkas: seluruh kotak lesi + margin, dijaga agar tetap di dalam foto.
  Rect _crop(ui.Image im) {
    if (widget.spots.isEmpty) {
      // Tanpa lesi, tunjukkan wajah seperti saat memotret.
      return const Rect.fromLTWH(0.0, 0.05, 1.0, 0.9);
    }
    var l = widget.spots.first.x - widget.spots.first.size;
    var t = widget.spots.first.y - widget.spots.first.size;
    var r = widget.spots.first.x + widget.spots.first.size;
    var b = widget.spots.first.y + widget.spots.first.size;
    for (final s in widget.spots.skip(1)) {
      l = math.min(l, s.x - s.size);
      t = math.min(t, s.y - s.size);
      r = math.max(r, s.x + s.size);
      b = math.max(b, s.y + s.size);
    }
    // Lebarkan supaya konteks di sekitar lesi ikut terlihat.
    final mx = (r - l) * 0.35;
    final my = (b - t) * 0.35;
    final wPx = (r - l + 2 * mx) * im.width;
    final hPx = (b - t + 2 * my) * im.height;
    final side = math.max(wPx, hPx);
    final cx = (l + r) / 2 * im.width;
    final cy = (t + b) / 2 * im.height;
    final left = (cx - side / 2).clamp(0, im.width - 1).toDouble();
    final top = (cy - side / 2).clamp(0, im.height - 1).toDouble();
    final right = math.min(left + side, im.width.toDouble());
    final bottom = math.min(top + side * 1.1, im.height.toDouble());
    return Rect.fromLTRB(
      left / im.width,
      top / im.height,
      right / im.width,
      bottom / im.height,
    );
  }

  @override
  Widget build(BuildContext context) {
    final im = _image;
    if (_failed) {
      return AspectRatio(
        aspectRatio: 3 / 4,
        child: CustomPaint(
          painter: _SchematicPainter(
            spots: widget.spots,
            emphasizedLabel: widget.emphasizedLabel,
          ),
        ),
      );
    }
    if (im == null) {
      return const AspectRatio(
        aspectRatio: 3 / 4,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final crop = _crop(im);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: (crop.width * im.width) / (crop.height * im.height),
        child: LayoutBuilder(
          builder: (context, box) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: widget.onTapCondition == null
                ? null
                : (d) => _tap(
                    widget.spots,
                    widget.onTapCondition!,
                    Offset(
                      crop.left + d.localPosition.dx / box.maxWidth * crop.width,
                      crop.top +
                          d.localPosition.dy / box.maxHeight * crop.height,
                    ),
                  ),
            child: CustomPaint(
              painter: _PhotoPainter(
                image: im,
                crop: crop,
                spots: widget.spots,
                emphasizedLabel: widget.emphasizedLabel,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoPainter extends CustomPainter {
  _PhotoPainter({
    required this.image,
    required this.crop,
    required this.spots,
    required this.emphasizedLabel,
  });

  final ui.Image image;
  final Rect crop;
  final List<ConditionSpot> spots;
  final SkinConditionLabel? emphasizedLabel;

  @override
  void paint(Canvas canvas, Size size) {
    final src = Rect.fromLTRB(
      crop.left * image.width,
      crop.top * image.height,
      crop.right * image.width,
      crop.bottom * image.height,
    );
    canvas.drawImageRect(
      image,
      src,
      Offset.zero & size,
      Paint()..filterQuality = FilterQuality.medium,
    );

    Rect toView(Rect r) => Rect.fromLTRB(
      (r.left - crop.left) / crop.width * size.width,
      (r.top - crop.top) / crop.height * size.height,
      (r.right - crop.left) / crop.width * size.width,
      (r.bottom - crop.top) / crop.height * size.height,
    );

    for (final s in spots) {
      final rect = toView(Rect.fromCenter(
        center: Offset(s.x, s.y),
        width: s.size,
        height: s.size,
      ));
      final color =
          AppColors.conditionColor(s.label.name);
      _paintSpotBox(canvas, rect, color, emphasizedLabel == s.label);
    }
  }

  @override
  bool shouldRepaint(_PhotoPainter old) =>
      old.image != image ||
      old.crop != crop ||
      old.spots != spots ||
      old.emphasizedLabel != emphasizedLabel;
}
