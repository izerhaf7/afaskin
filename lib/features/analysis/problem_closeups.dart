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
    this.probabilitas = const {},
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

  /// Keyakinan tiap kondisi, dipakai kartu untuk menunjukkan seberapa kuat
  /// buktinya. Kosong = tidak ditampilkan.
  final Map<SkinConditionLabel, double> probabilitas;

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

  /// Gambar foto depan yang sudah didekode, null selama belum siap.
  ui.Image? _image;

  /// Gambar foto samping, berurutan sesuai `widget.sidePhotos`.
  final List<ui.Image> _sideImages = [];

  /// Area yang benar-benar punya kartu, untuk mencocokkan id saat menyorot.
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
    if (old.sidePhotos.length != widget.sidePhotos.length) _decodeSides();
    // Dipilih dari peta wajah: geser baris supaya kartu area itu terlihat.
    if (old.selectedAreaId != widget.selectedAreaId &&
        widget.selectedAreaId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _geserKeArea(widget.selectedAreaId!);
      });
    }
  }

  /// Dekode foto depan. Gagal membaca foto bukan alasan menggagalkan seluruh
  /// halaman: sorotan cukup menampilkan keterangan bahwa fotonya tidak ada.
  Future<void> _decode() async {
    final jpeg = widget.photo;
    if (jpeg == null) return;
    final ui.FrameInfo frame;
    try {
      final codec = await ui.instantiateImageCodec(jpeg);
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

  /// Dekode semua foto samping yang ada.
  Future<void> _decodeSides() async {
    for (final b in widget.sidePhotos) {
      final ui.FrameInfo frame;
      try {
        final codec = await ui.instantiateImageCodec(b);
        frame = await codec.getNextFrame();
      } on Object {
        // Foto samping yang tidak bisa dibaca dilewati.
        continue;
      }
      if (!mounted) {
        frame.image.dispose();
        return;
      }
      _sideImages.add(frame.image);
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
        urutan: diView.length > 1 ? diView.indexOf(a) + 1 : null,
        urutanTotal: diView.length > 1 ? diView.length : null,
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
            area: c.area,
            keyakinan: widget.probabilitas[c.area.label],
            urutan: c.urutan,
            urutanTotal: c.urutanTotal,
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
    this.urutanTotal,
  });

  final LesionArea area;
  final ui.Image image;
  final Rect crop;

  /// Nomor kelompok bila dalam view itu ada lebih dari satu area.
  final int? urutan;

  /// Jumlah kelompok pada view itu, untuk ditampilkan "2 dari 5".
  final int? urutanTotal;
}

class _CloseupCard extends StatelessWidget {
  const _CloseupCard({
    required this.image,
    required this.crop,
    required this.area,
    required this.selected,
    required this.onTap,
    this.keyakinan,
    this.urutan,
    this.urutanTotal,
  });

  final ui.Image image;
  final Rect crop;
  final LesionArea area;

  /// Keyakinan kondisi ini (0-1). Null = tidak ditampilkan.
  final double? keyakinan;

  final int? urutan;
  final int? urutanTotal;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final warna = AppColors.conditionColor(area.label.name);
    final judul = AppStrings.condition(area.label);

    // Dulu kartu hanya berisi label dan "N lesi", yang tidak memberi tahu
    // apa pun tentang letak dan kekuatannya. Sekarang tiga baris informasi:
    //   baris 1  nama kondisi + nomor urut (kalau lebih dari satu area)
    //   baris 2  letak di wajah (Dahi / Pipi kiri / …)
    //   baris 3  jumlah lesi + keyakinan
    // Sengaja TIDAK memakai nama area wajah (Dahi/Pipi/Hidung/Dagu).
    // Diukur pada foto uji kepala menoleh: ujung hidung bergeser sampai 0,54
    // panjang batang hidung dari garis tengah, dan titik dagu 0,99, sehingga
    // kartu bertulis "Pipi kiri" bisa berisi hidung. Nama kondisi selalu benar
    // karena berasal dari lesi yang memang terdeteksi di situ. Sebagai gantinya
    // dipakai jumlah lesi dan luas area, yang dihitung dari data lesi itu
    // sendiri sehingga tidak bisa meleset.
    final jumlahTeks = area.jumlah > 1 ? '${area.jumlah} lesi' : '1 lesi';
    final luasTeks = _luasTeks(area);
    final keyakinanTeks = keyakinan == null
        ? null
        : '${(keyakinan! * 100).round()}%';

    return Semantics(
      button: onTap != null,
      selected: selected,
      label: [
        judul,
        if (urutan != null) 'area $urutan dari $urutanTotal',
        jumlahTeks,
        if (luasTeks != null) luasTeks,
        if (keyakinanTeks != null) 'keyakinan $keyakinanTeks',
      ].join(', '),
      child: SizedBox(
        width: _ProblemCloseupsState._cardWidth,
        child: Material(
          color: selected ? warna.withValues(alpha: 0.06) : AppColors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.cardAll,
            side: BorderSide(
              color: selected ? warna : AppColors.outline,
              width: selected ? 2 : 1,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 96,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ExcludeSemantics(
                        child: CustomPaint(painter: _CropPainter(image, crop)),
                      ),
                      // Penanda jumlah: angka besar di pojok, supaya mata bisa
                      // memindai "mana yang paling banyak" tanpa membaca teks.
                      if (area.jumlah > 1)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: warna,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${area.jumlah}',
                              style: text.labelSmall?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      // Nomor urut area, dipakai untuk mencocokkan dengan kotak
                      // di peta saat pengguna sedang menyorot.
                      if (urutan != null)
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.ink.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              urutanTotal == null
                                  ? '$urutan'
                                  : '$urutan/$urutanTotal',
                              style: text.labelSmall?.copyWith(
                                color: AppColors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 7, 10, 9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration:
                                BoxDecoration(color: warna, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              judul,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.titleSmall?.copyWith(fontSize: 12.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        [
                          jumlahTeks,
                          if (luasTeks != null) luasTeks,
                        ].join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall?.copyWith(
                          fontSize: 10.5,
                          color: AppColors.inkMuted,
                        ),
                      ),
                      if (keyakinanTeks != null) ...[
                        const SizedBox(height: 4),
                        _BarKeyakinan(
                          nilai: keyakinan!,
                          warna: warna,
                          teks: keyakinanTeks,
                        ),
                      ],
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

/// Batang kecil penanda keyakinan, warnanya sama dengan kondisi.
///
/// Angka persen saja sulit dibandingkan antar kartu; batang membuat perbedaan
/// 40% dan 80% langsung terbaca.
/// Seberapa luas area lesi ini, dalam kata.
///
/// Dipakai sebagai pengganti nama area wajah yang tidak andal. Ambangnya dari
/// sebaran kotak lesi di peta: di bawah 4% lebar foto itu satu titik kecil,
/// di atas 10% sudah satu bidang.
String? _luasTeks(LesionArea area) {
  final b = area.bounds;
  if (b.isEmpty) return null;
  final s = math.max(b.width, b.height);
  if (s < 0.04) return 'titik kecil';
  if (s < 0.10) return 'area kecil';
  if (s < 0.20) return 'area sedang';
  return 'area luas';
}

class _BarKeyakinan extends StatelessWidget {
  const _BarKeyakinan({
    required this.nilai,
    required this.warna,
    required this.teks,
  });

  final double nilai;
  final Color warna;
  final String teks;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: nilai.clamp(0.0, 1.0),
              minHeight: 3.5,
              backgroundColor: AppColors.outline.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation<Color>(warna),
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          teks,
          style: text.labelSmall?.copyWith(
            fontSize: 10,
            color: AppColors.inkMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
