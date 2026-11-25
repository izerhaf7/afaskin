import 'dart:math' as math;
import 'dart:ui' show Offset, Rect;

import 'package:afaskin/data/models/models.dart';

/// Satu **area lesi**: sekumpulan deteksi yang letaknya berdempetan dan
/// kondisinya sama, digabung menjadi satu kotak.
///
/// Kenapa digabung. Model memindai petak yang bertumpuk (stride 0,55 petak),
/// jadi satu lesi bisa menghasilkan dua atau tiga deteksi. Menggambar satu
/// kotak per deteksi membuat peta penuh kotak besar yang saling menimpa dan
/// lesinya justru tidak terbaca. Satu area = satu kotak = satu kartu sorotan,
/// sehingga ketukan pada kotak bisa menunjuk kartu yang tepat.
///
/// Kenapa kotaknya lebih kecil dari petak. Ukuran petak (15% lebar wajah) adalah
/// wilayah yang **dinilai** model, bukan ukuran lesinya. Lesi sendiri mengisi
/// sekitar seperempat petak, jadi kotak area dihitung dari perkiraan lesi
/// ([lesiRel] kali sisi petak), bukan dari sisi petak.
class LesionArea {
  const LesionArea({
    required this.id,
    required this.label,
    required this.viewIndex,
    required this.spots,
    required this.bounds,
  });

  /// Identitas stabil, dipakai bersama oleh peta wajah dan kartu sorotan.
  final String id;

  final SkinConditionLabel label;

  /// 0 = foto depan, 1 dan seterusnya = foto samping.
  final int viewIndex;

  final List<ConditionSpot> spots;

  /// Kotak area dalam koordinat ternormalisasi 0-1 terhadap foto view ini.
  final Rect bounds;

  Offset get center => bounds.center;

  int get jumlah => spots.length;
}

/// Porsi sisi petak yang diperkirakan ditempati lesi.
///
/// Diukur pada petak aplikasi: median porsi sisi lesi 0,26 dari sisi petak.
/// Dipakai 0,5 agar kotak sedikit lebih longgar dari lesi itu sendiri, supaya
/// lesi tidak terpotong garis, tetapi tetap jauh lebih kecil dari petaknya.
const double lesiRel = 0.5;

/// Jarak (proporsi lebar foto) di mana dua deteksi dianggap satu area.
///
/// Diturunkan dari 0,09 ke 0,05 karena penggabungan terjadi dua kali:
/// `gabungBertumpuk` di repositori sudah menyatukan petak satu lesi dan membatasi
/// luasnya, lalu fungsi ini menggabung lagi. Dengan 0,09, spot yang sudah
/// dipisah repositori menyatu kembali dan peta menggambar lebih sedikit kotak
/// daripada angka di chip kondisi — terlihat sebagai "chip menulis 4, peta
/// menggambar 2".
///
/// Diukur pada tiga foto uji dengan menghitung ulang kedua tahap
/// (`scripts/eksperimen/simulasi_gabung_ui.py`):
///
/// | foto                | spot repo | ui 0,09 | ui 0,05 |
/// |---------------------|-----------|---------|---------|
/// | jerawat_dan_bekas   |     5     |    2    |    5    |
/// | hanya_jerawat       |    10     |    5    |    9    |
/// | dahi_satu (1 lesi)  |     2     |    2    |    2    |
///
/// Pada 0,05 peta menggambar kotak sebanyak chip, dan satu lesi tunggal tetap
/// utuh (tidak pecah).
const double jarakArea = 0.05;

/// Batas sebaran satu area, sebagai proporsi lebar/tinggi foto.
///
/// Penggabungan bersifat transitif: A dekat B, B dekat C, sehingga rantai
/// deteksi bisa menyatukan lesi yang sebenarnya berjauhan dan kotaknya melebar
/// menutupi separuh wajah. Kalau batas ini terlampaui, tiap deteksi dipisah
/// menjadi areanya sendiri — kotaknya kembali mengikuti lesi, bukan wilayah.
const double batasArea = 0.30;

/// Susun area lesi dari kondisi hasil analisis.
///
/// Dikelompokkan per (kondisi, view) lalu secara transitif menurut jarak.
/// Urutannya: foto depan dulu, lalu tiap foto samping, dan di dalam satu view
/// diurutkan menurut jumlah lesi terbanyak supaya yang paling menonjol tampil
/// lebih dulu.
List<LesionArea> buildLesionAreas(
  List<SkinCondition> conditions, {
  double jarak = jarakArea,
}) {
  final hasil = <LesionArea>[];
  final views = <int>{
    for (final c in conditions)
      for (final s in c.spots) s.viewIndex,
  }.toList()
    ..sort();

  for (final v in views) {
    for (final c in conditions) {
      final diView = [
        for (final s in c.spots)
          if (s.viewIndex == v) s,
      ];
      if (diView.isEmpty) continue;
      final kelompok = kelompokkanLesi(diView, jarak: jarak);
      // Kelompok terbesar lebih dulu: itu yang paling ingin dilihat pengguna.
      kelompok.sort((a, b) => b.length.compareTo(a.length));
      for (var i = 0; i < kelompok.length; i++) {
        final b = kotakArea(kelompok[i]);
        final terlaluLuas =
            math.max(b.width, b.height) > batasArea && kelompok[i].length > 1;
        if (terlaluLuas) {
          // Rantai penggabungan menjangkau terlalu jauh: pisahkan per deteksi.
          for (var j = 0; j < kelompok[i].length; j++) {
            hasil.add(LesionArea(
              id: '${c.label.name}#$v#$i.$j',
              label: c.label,
              viewIndex: v,
              spots: [kelompok[i][j]],
              bounds: kotakArea([kelompok[i][j]]),
            ));
          }
          continue;
        }
        hasil.add(LesionArea(
          id: '${c.label.name}#$v#$i',
          label: c.label,
          viewIndex: v,
          spots: kelompok[i],
          bounds: b,
        ));
      }
    }
  }
  return hasil;
}

/// Kelompokkan deteksi yang berdekatan secara transitif.
///
/// Satu kelompok = satu lesi, atau sekumpulan lesi yang berdempetan pada satu
/// area dengan kondisi yang sama.
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

/// Kotak satu area, dihitung dari perkiraan luas lesi tiap deteksi.
///
/// Sengaja tidak memakai sisi petak penuh: petak adalah wilayah penilaian,
/// bukan lesi. Dengan [lesiRel] 0,5 kotak menjadi kira-kira separuh petak,
/// cukup untuk membingkai lesi tanpa menutupi separuh pipi.
Rect kotakArea(List<ConditionSpot> spots) {
  if (spots.isEmpty) return Rect.zero;
  var x1 = double.infinity, y1 = double.infinity;
  var x2 = -double.infinity, y2 = -double.infinity;
  for (final s in spots) {
    // `size` adalah sisi petak. Ia dibatasi karena nilai yang terlalu besar
    // (data uji lama memakai 0,40) akan menghasilkan kotak selebar seperempat
    // wajah — bertentangan dengan maksud kotak ini, yaitu mengikuti lesi.
    final sisi = s.size.clamp(0.02, 0.20);
    final half = math.max(sisi * lesiRel, 0.02) / 2;
    x1 = math.min(x1, s.x - half);
    y1 = math.min(y1, s.y - half);
    x2 = math.max(x2, s.x + half);
    y2 = math.max(y2, s.y + half);
  }
  // Sedikit ruang agar garis tidak menempel di lesi.
  final pad = math.max((x2 - x1), (y2 - y1)) * 0.12;
  return Rect.fromLTRB(
    (x1 - pad).clamp(0.0, 1.0),
    (y1 - pad).clamp(0.0, 1.0),
    (x2 + pad).clamp(0.0, 1.0),
    (y2 + pad).clamp(0.0, 1.0),
  );
}

/// Area pada titik [p] (0-1 terhadap foto view yang sedang ditampilkan).
///
/// Kotak yang memuat titik menang, dan di antara beberapa kotak yang sama-sama
/// memuat, yang **pusatnya paling dekat** dengan titik ketukan yang dipilih.
///
/// Sebelumnya pemenangnya kotak dengan luas terkecil. Begitu jumlah kotak
/// bertambah (setelah penggabungan di repositori tidak lagi menyatukan seluruh
/// bidang jerawat), banyak kotak saling bertumpuk dengan ukuran hampir sama.
/// Luasnya jadi seri, dan ketukan pada kotak kedua justru memilih kotak pertama
/// yang menumpukinya. Diukur di `region_selection_test`: mengetuk area
/// `acne#0#1` memilih `acne#0#0`.
///
/// Kalau tidak ada kotak yang memuat, dipilih area terdekat dalam jarak
/// [toleransi] agar ketukan jari tetap terasa responsif.
LesionArea? hitTestArea(
  List<LesionArea> areas,
  Offset p, {
  double toleransi = 0.035,
}) {
  LesionArea? best;
  var bestJarak = double.infinity;
  var bestArea = double.infinity;
  for (final a in areas) {
    if (!a.bounds.contains(p)) continue;
    final d = (a.center - p).distance;
    final luas = a.bounds.width * a.bounds.height;
    // Pusat terdekat menang; luas hanya dipakai memutus seri.
    if (d < bestJarak - 1e-9 || (d <= bestJarak + 1e-9 && luas < bestArea)) {
      bestJarak = d;
      bestArea = luas;
      best = a;
    }
  }
  if (best != null) return best;

  var jauh = toleransi;
  for (final a in areas) {
    final d = (a.center - p).distance;
    if (d < jauh) {
      jauh = d;
      best = a;
    }
  }
  return best;
}
