import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_spacing.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/features/analysis/lesion_areas.dart';
import 'package:material_ui/material_ui.dart';

export 'package:afaskin/features/analysis/lesion_areas.dart'
    show kelompokkanLesi, kotakArea, LesionArea, lesiRel;

/// Sorotan lesi: potongan foto yang diperbesar tepat di lokasi lesi.
///
/// Peta wajah menjawab "di mana", bagian ini menjawab "seperti apa bentuknya".
/// Satu kartu = satu **area lesi** dari `buildLesionAreas`, sehingga kartu dan
/// kotak di peta punya identitas yang sama: menekan sebuah kotak bisa
/// menggulir ke kartu area itu, dan sebaliknya.
///
/// Label kartu adalah nama kondisi, bukan nama area wajah. Alasannya terukur
/// pada foto uji kepala menoleh: posisi ujung hidung bergeser sampai 0,54
/// panjang batang hidung dari garis tengah wajah, dan titik dagu 0,99.
/// Penamaan area (dahi/pipi/hidung/dagu) bergantung pada landmark itu, sehingga
/// kartu bertuliskan "Pipi kiri" bisa berisi hidung. Nama kondisi selalu benar
/// karena berasal dari lesi yang memang terdeteksi di situ.
///
/// Foto hanya ada di memori, jadi baris ini kosong untuk analisis dari Riwayat.
class ProblemCloseups extends StatefulWidget {
  const ProblemCloseups({
    required this.areas,
    super.key,
    this.photo,
    this.sidePhotos = const [],
    this.selectedAreaId,
    this.onTapArea,
  });

  /// Foto depan analisis ini, atau null kalau sudah tidak di memori.
  final Uint8List? photo;

  /// Foto samping (hanya di memori). Lesi yang terlihat dari samping ikut
  /// disorot dari foto samping, bukan hanya dari foto depan.
  final List<Uint8List> sidePhotos;

  /// Area lesi dari `buildLesionAreas`, termasuk yang berasal dari foto samping.
  final List<LesionArea> areas;

  /// Area yang sedang disorot (dari peta wajah atau kartu lesi).
  final String? selectedAreaId;

  /// Dipanggil saat kartu sorotan diketuk. Null = kartu tidak bisa diketuk.
  final ValueChanged<LesionArea>? onTapArea;

  @override
  State<ProblemCloseups> createState() => _ProblemCloseupsState();
}

/// Kotak potong untuk satu kelompok lesi, dalam piksel gambar.
///
/// Sisi dibatasi 32% lebar foto: cukup untuk melihat latar lesinya, tapi tidak
/// sampai selebar wajah sehingga potongannya tetap terasa "diperbesar".
Rect kotakSorotan(List<ConditionSpot> spots, double lebar, double tinggi) {
  var x1 = double.infinity, y1 = double.infinity;
  var x2 = -double.infinity, y2 = -double.infinity;
  for (final s in spots) {
    // `size` dinormalisasi terhadap lebar foto (lihat ConditionSpot).
    final half = math.max(s.size, 0.02) * lebar / 2;
    final cx = s.x * lebar, cy = s.y * tinggi;
    x1 = math.min(x1, cx - half);
    y1 = math.min(y1, cy - half);
    x2 = math.max(x2, cx + half);
    y2 = math.max(y2, cy + half);
  }
  // Margin konteks di sekeliling lesi.
  final mx = (x2 - x1) * 0.45, my = (y2 - y1) * 0.45;
  final cxc = (x1 + x2) / 2, cyc = (y1 + y2) / 2;
  final side = math.min(
    math.max(x2 - x1 + 2 * mx, y2 - y1 + 2 * my),
    lebar * 0.32,
  );
  final s = math.max(side, lebar * 0.18);
  final l = (cxc - s / 2).clamp(0.0, math.max(0.0, lebar - s)).toDouble();
  final t = (cyc - s / 2).clamp(0.0, math.max(0.0, tinggi - s)).toDouble();
  return Rect.fromLTWH(l, t, s, s);
}

/// Kotak potong untuk satu area, memakai batas areanya.
///
/// Berbeda dari [kotakSorotan] yang memakai sisi petak: di sini batasnya sudah
/// mengelilingi lesi, jadi potongan mengikuti bentuk area dan tidak melebar
/// hanya karena petaknya besar.
Rect kotakSorotanArea(LesionArea area, double lebar, double tinggi) {
  final b = area.bounds;
  var x1 = b.left * lebar, y1 = b.top * tinggi;
  var x2 = b.right * lebar, y2 = b.bottom * tinggi;
  final mx = (x2 - x1) * 0.45, my = (y2 - y1) * 0.45;
  final cxc = (x1 + x2) / 2, cyc = (y1 + y2) / 2;
  final side = math.min(
    math.max(x2 - x1 + 2 * mx, y2 - y1 + 2 * my),
    lebar * 0.32,
  );
  final s = math.max(side, lebar * 0.18);
  final l = (cxc - s / 2).clamp(0.0, math.max(0.0, lebar - s)).toDouble();
  final t = (cyc - s / 2).clamp(0.0, math.max(0.0, tinggi - s)).toDouble();
  return Rect.fromLTWH(l, t, s, s);
}

class _ProblemCloseupsState extends State<ProblemCloseups> {
  static const double _cardWidth = 132;
  static const double _gap = AppSpacing.xs;

  /// Batas jumlah kartu; lebih dari ini barisnya terlalu panjang untuk digeser.
  static const int _maksKartu = 10;

  final ScrollController _scroll = ScrollController();
  ui.Image? _image;
  final List<ui.Image> _sideImages = [];

  /// Area yang benar-benar punya kartu, dengan urutan yang sama seperti baris.
  List<LesionArea> _kartu = const [];

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
    // Dipilih dari peta wajah: geser baris supaya kartu area itu terlihat.
    if (old.selectedAreaId != widget.selectedAreaId &&
        widget.selectedAreaId != null) {
      _geserKeArea(widget.selectedAreaId!);
    }
  }

  /// Geser baris kartu ke area terpilih.
  ///
  /// Memakai indeks area yang benar-benar punya kartu, bukan indeks kondisi:
  /// satu kondisi bisa punya beberapa area, dan sebelumnya semua area kondisi
  /// itu bergulir ke kartu pertama sehingga kartu yang dituju tidak terlihat.
  void _geserKeArea(String id) {
    final i = _kartu.indexWhere((a) => a.id == id);
    if (i < 0 || !_scroll.hasClients) return;
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

  /// Gambar yang dipakai satu area: foto depan atau foto samping ke-(n).
  ui.Image? _gambarUntuk(LesionArea a) {
    if (a.viewIndex == 0) return _image;
    final i = a.viewIndex - 1;
    return i < _sideImages.length ? _sideImages[i] : null;
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final im = _image;
    if (im == null) {
      return Text(AppStrings.closeupNoPhoto, style: text.bodySmall);
    }

    // Satu kartu per area, urutannya sudah foto depan lebih dulu lalu samping.
    final kartu = <_CardSpec>[];
    for (final a in widget.areas) {
      final gambar = _gambarUntuk(a);
      if (gambar == null) continue;
      final diView = [
        for (final x in widget.areas)
          if (x.viewIndex == a.viewIndex) x,
      ];
      kartu.add(_CardSpec(
        area: a,
        image: gambar,
        crop: kotakSorotanArea(a, gambar.width.toDouble(), gambar.height.toDouble()),
        urutan: diView.length > 1 && diView.indexOf(a) > 0
            ? diView.indexOf(a) + 1
            : null,
      ));
      if (kartu.length >= _maksKartu) break;
    }
    if (kartu.isEmpty) {
      return Text(AppStrings.closeupNoPhoto, style: text.bodySmall);
    }
    _kartu = [for (final c in kartu) c.area];

    return SizedBox(
      height: 176,
      child: ListView.separated(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        itemCount: kartu.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, i) {
          final c = kartu[i];
          return _CloseupCard(
            image: c.image,
            crop: c.crop,
            label: AppStrings.condition(c.area.label),
            viewLabel: c.area.viewIndex == 0
                ? null
                : 'Samping ${c.area.viewIndex}',
            jumlah: c.area.jumlah,
            urutan: c.urutan,
            selected: widget.selectedAreaId == c.area.id,
            onTap: widget.onTapArea == null
                ? null
                : () => widget.onTapArea!(c.area),
          );
        },
      ),
    );
  }
}

/// Satu kartu sorotan: foto mana yang dipotong dan di mana.
class _CardSpec {
  const _CardSpec({
    required this.area,
    required this.image,
    required this.crop,
    this.urutan,
  });

  final LesionArea area;
  final ui.Image image;
  final Rect crop;

  /// Nomor kelompok bila dalam view itu ada lebih dari satu area.
  final int? urutan;
}

class _CloseupCard extends StatelessWidget {
  const _CloseupCard({
    required this.image,
    required this.crop,
    required this.label,
    required this.jumlah,
    required this.selected,
    required this.onTap,
    this.urutan,
    this.viewLabel,
  });

  final ui.Image image;
  final Rect crop;
  final String label;
  final int jumlah;
  final int? urutan;

  /// "Samping 1" dst. Null untuk foto depan.
  final String? viewLabel;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final judul = urutan == null ? label : '$label · ${urutan!}';
    final sub = [
      if (viewLabel != null) viewLabel!,
      jumlah > 1 ? '$jumlah lesi' : '1 lesi',
    ].join(' · ');
    return Semantics(
      button: onTap != null,
      label: '$judul, $sub',
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
                        judul,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleSmall?.copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        maxLines: 1,
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
