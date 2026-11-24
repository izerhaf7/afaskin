import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/features/analysis/lesion_areas.dart';
import 'package:material_ui/material_ui.dart';

/// Peta wajah yang memetakan **lesi**, bukan pembagian wajah yang kasar.
///
/// Tiap area lesi digambar sebagai satu kotak yang mengelilingi lesinya, jadi
/// yang terlihat adalah area yang bermasalah — bukan wilayah petak yang dinilai
/// model. Beberapa deteksi pada satu area dengan kondisi sama digabung menjadi
/// satu kotak (lihat [LesionArea]).
///
/// Dengan [photo] (hanya tepat setelah analisis; foto hidup di memori dan tidak
/// pernah disimpan) kotak lesi dilukis di atas foto pengguna. Tanpa foto,
/// digambar di atas siluet wajah skematik dengan asumsi wajah memenuhi bingkai
/// panduan — sama seperti saat memotret.

/// Kondisi pada titik [p] (dinormalisasi 0-1 terhadap foto), atau null kalau
/// di luar semua kotak lesi. Dipertahankan untuk pemanggil lama.
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
    required this.areas,
    super.key,
    this.photo,
    this.selectedAreaId,
    this.onTapArea,
  });

  /// Foto depan (JPEG) dari analisis ini, atau null.
  final Uint8List? photo;

  /// Area lesi pada **foto depan** saja. Lesi dari foto samping ditampilkan
  /// pada sorotan areanya sendiri, karena koordinatnya relatif terhadap foto
  /// samping, bukan foto depan.
  final List<LesionArea> areas;

  /// Area yang sedang disorot, supaya kotaknya digambar lebih tegas.
  final String? selectedAreaId;

  /// Dipanggil saat sebuah kotak area diketuk. Null = peta tidak bisa diketuk.
  final ValueChanged<LesionArea>? onTapArea;

  @override
  Widget build(BuildContext context) {
    final labels = [
      for (final c in {for (final a in areas) a.label})
        AppStrings.condition(c),
    ];
    final photo = this.photo;
    if (photo != null) {
      return Semantics(
        image: true,
        label: '${AppStrings.faceMapHeading}: ${labels.join(', ')}',
        child: _PhotoFaceMap(
          jpeg: photo,
          areas: areas,
          selectedAreaId: selectedAreaId,
          onTapArea: onTapArea,
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
            onTapUp: onTapArea == null
                ? null
                : (d) => _tapArea(
                    areas,
                    onTapArea!,
                    Offset(
                      d.localPosition.dx / box.maxWidth,
                      d.localPosition.dy / box.maxHeight,
                    ),
                  ),
            child: CustomPaint(
              painter: _SchematicPainter(
                areas: areas,
                selectedAreaId: selectedAreaId,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void _tapArea(
  List<LesionArea> areas,
  ValueChanged<LesionArea> onTap,
  Offset p,
) {
  final area = hitTestArea(areas, p);
  if (area != null) onTap(area);
}

/// Kotak lesi: isi tipis + garis tegas, lebih kuat saat areanya disorot.
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
  _SchematicPainter({required this.areas, required this.selectedAreaId});

  final List<LesionArea> areas;
  final String? selectedAreaId;

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

    for (final a in areas) {
      final b = a.bounds;
      final box = Rect.fromLTRB(
        b.left * size.width,
        b.top * size.height,
        b.right * size.width,
        b.bottom * size.height,
      );
      final color = AppColors.conditionColor(a.label.name);
      _paintSpotBox(canvas, box, color, selectedAreaId == a.id);
    }
  }

  @override
  bool shouldRepaint(_SchematicPainter old) =>
      old.areas != areas || old.selectedAreaId != selectedAreaId;
}

/// Kotak lesi di atas foto pengguna, dipangkas mengelilingi lesi.
class _PhotoFaceMap extends StatefulWidget {
  const _PhotoFaceMap({
    required this.jpeg,
    required this.areas,
    required this.selectedAreaId,
    required this.onTapArea,
  });

  final Uint8List jpeg;
  final List<LesionArea> areas;
  final String? selectedAreaId;
  final ValueChanged<LesionArea>? onTapArea;

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
  ///
  /// Ada batas bawah ukuran potongan. Tanpa itu, dua lesi yang berdekatan
  /// membuat `side` hanya sepersepuluh lebar foto, sehingga peta hasil tampak
  /// sangat diperbesar dan wajahnya terpotong — pengguna membaca ini sebagai
  /// "hasilnya kecrop". Dengan batas 0,62 lebar foto, konteks wajah tetap
  /// terlihat sementara lesi masih terbaca.
  Rect _crop(ui.Image im) {
    if (widget.areas.isEmpty) {
      // Tanpa lesi, tunjukkan wajah seperti saat memotret.
      return const Rect.fromLTWH(0.0, 0.05, 1.0, 0.9);
    }
    var l = widget.areas.first.bounds.left;
    var t = widget.areas.first.bounds.top;
    var r = widget.areas.first.bounds.right;
    var b = widget.areas.first.bounds.bottom;
    for (final a in widget.areas.skip(1)) {
      l = math.min(l, a.bounds.left);
      t = math.min(t, a.bounds.top);
      r = math.max(r, a.bounds.right);
      b = math.max(b, a.bounds.bottom);
    }
    // Lebarkan supaya konteks di sekitar lesi ikut terlihat.
    final mx = (r - l) * 0.35;
    final my = (b - t) * 0.35;
    final wPx = (r - l + 2 * mx) * im.width;
    final hPx = (b - t + 2 * my) * im.height;
    final side = math.max(wPx, hPx);
    final cx = (l + r) / 2 * im.width;
    final cy = (t + b) / 2 * im.height;

    // Sisi minimum: 62% lebar foto (atau seluruh tinggi bila fotonya pendek),
    // supaya peta tidak menjadi potongan zoom ekstrem di sekitar satu lesi.
    final minSide = math.min(im.width * 0.62, im.height * 0.9);
    final s = math.max(side, minSide);

    final left = (cx - s / 2).clamp(0, math.max(0, im.width - s)).toDouble();
    final top = (cy - s / 2).clamp(0, math.max(0, im.height - s)).toDouble();
    final right = math.min(left + s, im.width.toDouble());
    final bottom = math.min(top + s, im.height.toDouble());
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
            areas: widget.areas,
            selectedAreaId: widget.selectedAreaId,
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
            onTapUp: widget.onTapArea == null
                ? null
                : (d) => _tapArea(
                    widget.areas,
                    widget.onTapArea!,
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
                areas: widget.areas,
                selectedAreaId: widget.selectedAreaId,
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
    required this.areas,
    required this.selectedAreaId,
  });

  final ui.Image image;
  final Rect crop;
  final List<LesionArea> areas;
  final String? selectedAreaId;

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

    for (final a in areas) {
      final rect = toView(a.bounds);
      final color = AppColors.conditionColor(a.label.name);
      _paintSpotBox(canvas, rect, color, selectedAreaId == a.id);
    }
  }

  @override
  bool shouldRepaint(_PhotoPainter old) =>
      old.image != image ||
      old.crop != crop ||
      old.areas != areas ||
      old.selectedAreaId != selectedAreaId;
}
