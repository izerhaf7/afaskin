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

/// Sorotan lesi: potongan foto yang diperbesar tepat di lokasi lesi.
///
/// Peta wajah menjawab "di mana", bagian ini menjawab "seperti apa bentuknya".
/// Satu kartu = satu **kelompok lesi yang berdekatan**, dipotong ketat di
/// sekelilingnya.
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
    required this.conditions,
    super.key,
    this.photo,
    this.sidePhotos = const [],
    this.selected,
    this.onTapCondition,
  });

  /// Foto depan analisis ini, atau null kalau sudah tidak di memori.
  final Uint8List? photo;

  /// Foto samping (hanya di memori). Lesi yang terlihat dari samping ikut
  /// disorot dari foto samping, bukan hanya dari foto depan.
  final List<Uint8List> sidePhotos;

  /// Kondisi beserta lokasi lesinya (0 = foto depan, 1+ = foto samping).
  final List<SkinCondition> conditions;

  /// Kondisi yang sedang disorot (dari peta wajah atau kartu lesi).
  final SkinConditionLabel? selected;

  /// Dipanggil saat kartu sorotan diketuk. Null = kartu tidak bisa diketuk.
  final ValueChanged<SkinConditionLabel>? onTapCondition;

  @override
  State<ProblemCloseups> createState() => _ProblemCloseupsState();
}

/// Kelompokkan lesi yang berdekatan (transitif): satu kelompok = satu lesi
/// atau sekumpulan lesi yang berdempetan.
///
/// Dipisah dari widget supaya bisa diuji tanpa mendekode foto.
List<List<ConditionSpot>> kelompokkanLesi(
  List<ConditionSpot> spots, {
  double jarak = 0.07,
}) {
  if (spots.isEmpty) return const [];
  final sisa = List<int>.generate(spots.length, (i) => i);
  final hasil = <List<ConditionSpot>>[];
  while (sisa.isNotEmpty) {
    final anggota = <int>[sisa.removeAt(0)];
    var berubah = true;
    while (berubah) {
      berubah = false;
      for (var j = sisa.length - 1; j >= 0; j--) {
        final p = spots[sisa[j]];
        final dekat = anggota.any((k) {
          final q = spots[k];
          final dx = q.x - p.x, dy = q.y - p.y;
          return dx * dx + dy * dy < jarak * jarak;
        });
        if (dekat) {
          anggota.add(sisa.removeAt(j));
          berubah = true;
        }
      }
    }
    hasil.add([for (final i in anggota) spots[i]]);
  }
  return hasil;
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

class _ProblemCloseupsState extends State<ProblemCloseups> {
  static const double _cardWidth = 132;
  static const double _gap = AppSpacing.xs;

  /// Lesi yang pusatnya lebih dekat dari ini (proporsi lebar foto) dianggap
  /// satu kelompok dan digabung dalam satu kartu.
  static const double _jarakKelompok = 0.07;

  /// Batas jumlah kartu; lebih dari ini barisnya terlalu panjang untuk digeser.
  static const int _maksKartu = 10;

  final ScrollController _scroll = ScrollController();
  ui.Image? _image;
  final List<ui.Image> _sideImages = [];

  /// Urutan kondisi yang kartunya muncul, untuk menyelaraskan scroll.
  List<SkinConditionLabel> _urutanKondisi() => [
    for (final c in widget.conditions)
      if (c.spots.isNotEmpty) c.label,
  ];

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
    // Dipilih dari peta wajah: geser baris supaya kartu kondisi itu terlihat.
    if (old.selected != widget.selected && widget.selected != null) {
      final i = _urutanKondisi().indexOf(widget.selected!);
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

  /// Potong ketat di sekeliling satu kelompok lesi, dengan sedikit konteks.
  Rect _cropAround(List<ConditionSpot> spots, ui.Image im) =>
      kotakSorotan(spots, im.width.toDouble(), im.height.toDouble());

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final im = _image;
    if (im == null) {
      return AfaCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(AppStrings.closeupNoPhoto, style: text.bodySmall),
      );
    }

    // Satu kartu per kelompok lesi; foto depan lebih dulu, lalu foto samping.
    final cards = <_CardSpec>[];
    for (final c in widget.conditions) {
      final depan = [
        for (final s in c.spots)
          if (s.viewIndex == 0) s,
      ];
      final kelompok = kelompokkanLesi(depan, jarak: _jarakKelompok);
      for (var i = 0; i < kelompok.length; i++) {
        cards.add(_CardSpec(
          image: im,
          crop: _cropAround(kelompok[i], im),
          label: c.label,
          jumlah: kelompok[i].length,
          urutan: kelompok.length > 1 ? i + 1 : null,
        ));
      }
      for (var v = 0; v < _sideImages.length; v++) {
        final samping = [
          for (final s in c.spots)
            if (s.viewIndex == v + 1) s,
        ];
        if (samping.isEmpty) continue;
        cards.add(_CardSpec(
          image: _sideImages[v],
          crop: _cropAround(samping, _sideImages[v]),
          label: c.label,
          jumlah: samping.length,
          viewLabel: 'Samping ${v + 1}',
        ));
      }
      if (cards.length >= _maksKartu) break;
    }
    if (cards.isEmpty) {
      return AfaCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(AppStrings.closeupNoPhoto, style: text.bodySmall),
      );
    }
    final tampil = cards.take(_maksKartu).toList();

    return SizedBox(
      height: 176,
      child: ListView.separated(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        itemCount: tampil.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, i) {
          final c = tampil[i];
          return _CloseupCard(
            image: c.image,
            crop: c.crop,
            label: AppStrings.condition(c.label),
            viewLabel: c.viewLabel,
            jumlah: c.jumlah,
            urutan: c.urutan,
            selected: widget.selected == c.label,
            onTap: widget.onTapCondition == null
                ? null
                : () => widget.onTapCondition!(c.label),
          );
        },
      ),
    );
  }
}

/// Satu kartu sorotan: foto mana yang dipotong dan di mana.
class _CardSpec {
  const _CardSpec({
    required this.image,
    required this.crop,
    required this.label,
    required this.jumlah,
    this.urutan,
    this.viewLabel,
  });

  final ui.Image image;
  final Rect crop;
  final SkinConditionLabel label;

  /// Jumlah lesi dalam kelompok ini.
  final int jumlah;

  /// Nomor kelompok bila kondisinya punya lebih dari satu kelompok lesi.
  final int? urutan;
  final String? viewLabel;
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
