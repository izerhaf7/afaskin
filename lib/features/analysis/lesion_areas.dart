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
/// Nilai 0,05 ternyata masih menghasilkan kotak bertumpuk. Penyebabnya bukan
/// jarak antar deteksi, melainkan **sisi kotaknya sendiri**:
///
///   spot.size (sisi petak)        0,15 lebar foto
///   kotak UI = size x lesiRel     0,15 x 0,5          = 0,075
///   ditambah pad 12% (dua sisi)   0,075 x 1,24        = 0,093
///
/// Dua deteksi yang berjarak 0,05 tetap dianggap terpisah walau kotaknya bersisi
/// 0,093, sehingga kotak itu menumpuk 46% dari sisinya. Di layar terlihat
/// sebagai tumpukan kotak yang berantakan.
///
/// Sekarang jaraknya disamakan dengan sisi kotak: deteksi yang lebih rapat dari
/// 0,095 digabung menjadi satu kotak, jadi kotak sejenis tidak mungkin bertumpuk.
/// Ini juga sesuai permintaan "yang berdekatan jadi satu kotak besar".
const double jarakArea = 0.095;

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
        // Dulu kelompok yang melebar melebihi [batasArea] dipecah menjadi satu
        // kotak per deteksi. Cara itu justru menghasilkan kotak yang saling
        // menimpa, karena deteksi yang berdekatan memang bertetangga. Sekarang
        // kelompok tetap satu kotak: itu memang satu bidang lesi, dan pengguna
        // memintanya sebagai "satu kotak besar untuk lesi yang berdekatan".
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

/// Jarak sebuah titik ke **tepi** kotak. 0 berarti titik ada di dalam kotak.
///
/// Dulu jaraknya diukur dari pusat kotak. Akibatnya kotak yang lebar pun sulit
/// ditekan: mengetuk tepat di dalam area kotak besar masih bisa kalah oleh
/// kotak kecil lain yang pusatnya kebetulan lebih dekat, dan ketukan di tepi
/// kotak besar tidak terasa sama sekali. Keluhan pengguna: "beberapa petak tidak
/// mengarah ke sorotan saat ditekan".
double _jarakKeTepi(Rect r, Offset p) {
  final dx = math.max(math.max(r.left - p.dx, p.dx - r.right), 0.0);
  final dy = math.max(math.max(r.top - p.dy, p.dy - r.bottom), 0.0);
  return math.sqrt(dx * dx + dy * dy);
}

/// Area pada titik [p] (0-1 terhadap foto view yang sedang ditampilkan).
///
/// Yang dipilih: kotak dengan **jarak terkeci ke tepi** titik ketukan. Kotak
/// yang memuat titik selalu menang (jaraknya 0); di antara kotak yang sama-sama
/// memuat, yang lebih kecil menang supaya area sempit tidak tertelan area luas.
///
/// Sebelumnya jaraknya diukur dari pusat kotak, sehingga ketukan tepat di atas
/// lesi kecil bisa meleset ke luar kotak dan tidak menyorot apa pun. Kotak di
/// peta bisa bersisi 0,04 lebar foto, jauh lebih kecil dari jari.
///
/// Kalau tidak ada kotak yang memuat maupun berdekatan, hasilnya null dan
/// halaman tidak menggulir ke mana-mana.
LesionArea? hitTestArea(
  List<LesionArea> areas,
  Offset p, {
  double toleransi = 0.045,
}) {
  if (areas.isEmpty) return null;
  LesionArea? best;
  var bestJarak = double.infinity;
  var bestLuas = double.infinity;
  for (final a in areas) {
    final d = _jarakKeTepi(a.bounds, p);
    if (d > toleransi) continue;
    final luas = a.bounds.width * a.bounds.height;
    // Dalam kotak (d == 0): yang paling kecil menang.
    // Di luar kotak: yang paling dekat menang.
    final lebihBaik = d < bestJarak - 1e-9 ||
        ((d - bestJarak).abs() <= 1e-9 && luas < bestLuas);
    if (lebihBaik) {
      bestJarak = d;
      bestLuas = luas;
      best = a;
    }
  }
  return best;
}
