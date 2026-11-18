import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/features/analysis/problem_closeups.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Sorotan lesi harus menunjuk isi gambarnya sendiri.
///
/// Dulu kartu diberi nama area (dahi/pipi/hidung/dagu) yang dihitung dari
/// landmark. Pada foto kepala menoleh, landmark meleset sampai setengah lebar
/// wajah — ujung hidung bergeser 0,54 panjang batang hidung dari garis tengah,
/// dan titik dagu 0,99 — sehingga kartu bertuliskan "Pipi kiri" bisa berisi
/// hidung. Sekarang satu kartu = satu kelompok lesi dan judulnya nama kondisi,
/// yang selalu benar karena berasal dari lesi yang memang terdeteksi.
ConditionSpot _spot(double x, double y, {double size = 0.1}) => ConditionSpot(
  x: x,
  y: y,
  size: size,
  label: SkinConditionLabel.scars,
  region: FaceRegion.forehead,
);

void main() {
  group('kelompokkanLesi', () {
    test('daftar kosong aman', () {
      expect(kelompokkanLesi(const []), isEmpty);
    });

    test('satu lesi jadi satu kelompok', () {
      expect(kelompokkanLesi([_spot(0.5, 0.5)]).length, 1);
    });

    test('tiga lesi berdempetan jadi satu kelompok', () {
      final k = kelompokkanLesi([
        _spot(0.50, 0.50),
        _spot(0.52, 0.51),
        _spot(0.51, 0.53),
      ]);
      expect(k.length, 1);
      expect(k.first.length, 3);
    });

    test('lesi berjauhan jadi kelompok terpisah', () {
      final k = kelompokkanLesi([_spot(0.2, 0.3), _spot(0.8, 0.7)]);
      expect(k.length, 2);
    });

    test('penggabungan bersifat transitif lewat rantai lesi', () {
      // A-B dan B-C berdekatan, A-C berjauhan: semuanya satu kelompok.
      final k = kelompokkanLesi(
        [_spot(0.40, 0.50), _spot(0.47, 0.50), _spot(0.54, 0.50)],
        jarak: 0.09,
      );
      expect(k.length, 1);
      expect(k.first.length, 3);
    });

    test('jarak dapat diatur', () {
      final spots = [_spot(0.40, 0.50), _spot(0.55, 0.50)];
      expect(kelompokkanLesi(spots, jarak: 0.20).length, 1);
      expect(kelompokkanLesi(spots, jarak: 0.05).length, 2);
    });
  });

  group('kotakSorotan', () {
    test('mengelilingi lesi dengan margin konteks', () {
      final r = kotakSorotan([_spot(0.5, 0.5, size: 0.1)], 600, 800);
      // Pusat lesi di (300, 400); potongan harus memuat titik itu.
      expect(r.contains(const Offset(300, 400)), isTrue);
      expect(r.width, r.height, reason: 'potongan selalu persegi');
    });

    test('sisi tidak melebihi 32% lebar foto', () {
      // Dua lesi berjauhan: tanpa batas, potongan bisa selebar foto.
      final r = kotakSorotan(
        [_spot(0.05, 0.5), _spot(0.95, 0.5)],
        600,
        800,
      );
      expect(r.width, lessThanOrEqualTo(600 * 0.32 + 1e-9));
    });

    test('sisi minimum 18% lebar foto supaya tidak terlalu sempit', () {
      final r = kotakSorotan([_spot(0.5, 0.5, size: 0.01)], 600, 800);
      expect(r.width, greaterThanOrEqualTo(600 * 0.18 - 1e-9));
    });

    test('tetap di dalam foto walau lesi di tepi', () {
      final r = kotakSorotan([_spot(0.99, 0.99)], 600, 800);
      expect(r.right, lessThanOrEqualTo(600 + 1e-9));
      expect(r.bottom, lessThanOrEqualTo(800 + 1e-9));
      expect(r.left, greaterThanOrEqualTo(-1e-9));
      expect(r.top, greaterThanOrEqualTo(-1e-9));
    });
  });
}
