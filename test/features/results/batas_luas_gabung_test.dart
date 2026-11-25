import 'package:afaskin/data/repositories/analysis_repository_local.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pada foto yang penuh jerawat, aplikasi hanya menggambar 2 kotak padahal
/// lesinya belasan. Penyebabnya aturan gabung: jarak antar petak hanya 0,55 sisi
/// petak, sedangkan ambang gabung 0,75 sisi, sehingga setiap petak bertetangga
/// SELALU menyatu dan satu bidang jerawat menjadi satu kotak raksasa.
///
/// Sekarang penggabungan dibatasi luas 0,10 lebar foto. Tes ini mengunci agar
/// perbaikan itu tidak hilang lagi.
Map<String, Object> _spot(double x, double y, {double size = 0.074}) => {
  'x': x,
  'y': y,
  'size': size,
  'label': 'acne',
  'region': 'right_cheek',
  'view_index': 0,
};

void main() {
  group('batas luas penggabungan', () {
    test('bidang jerawat yang lebar tidak menjadi satu kotak', () {
      // 4x4 petak berjarak 0,06, membentuk bidang selebar 0,18 + sisi petak
      // 0,074 = 0,254 lebar foto. Itu bidang jerawat, bukan satu lesi, jadi
      // harus terpecah. (Tiga petak rapat selebar 0,156 justru digabung menjadi
      // satu kotak, sesuai permintaan "yang berdekatan jadi satu kotak besar".)
      final spots = <Map<String, Object>>[
        for (var iy = 0; iy < 4; iy++)
          for (var ix = 0; ix < 4; ix++)
            _spot(0.40 + ix * 0.06, 0.55 + iy * 0.06),
      ];
      final hasil = gabungBertumpuk(spots);
      expect(hasil.length, greaterThan(1),
          reason: 'satu bidang jerawat harus terpecah, bukan satu kotak raksasa');
    });

    test('satu lesi kecil tetap satu kotak, tidak pecah', () {
      // Petak-petak yang menutupi satu lesi, jarak rapat.
      final spots = <Map<String, Object>>[
        _spot(0.500, 0.300),
        _spot(0.520, 0.300),
        _spot(0.500, 0.320),
      ];
      expect(gabungBertumpuk(spots), hasLength(1));
    });

    test('dua lesi berjauhan tetap dua kotak', () {
      final hasil = gabungBertumpuk([
        _spot(0.30, 0.60),
        _spot(0.70, 0.60),
      ]);
      expect(hasil, hasLength(2));
    });

    test('kelompok yang menyebar tidak pernah melebihi batas luas', () {
      // Deretan panjang: tanpa batas luas ini menyatu seluruhnya.
      final spots = <Map<String, Object>>[
        for (var i = 0; i < 8; i++) _spot(0.20 + i * 0.04, 0.50),
      ];
      final hasil = gabungBertumpuk(spots);
      expect(hasil.length, greaterThan(1));
      for (final h in hasil) {
        expect(h['size']! as double, lessThanOrEqualTo(0.45));
      }
    });

    test('semua kotak hasil tetap membawa data yang dibutuhkan peta', () {
      final spots = <Map<String, Object>>[
        for (var i = 0; i < 6; i++) _spot(0.30 + i * 0.05, 0.40),
      ];
      for (final h in gabungBertumpuk(spots)) {
        expect(h.containsKey('x'), isTrue);
        expect(h.containsKey('y'), isTrue);
        expect(h.containsKey('size'), isTrue);
        expect(h['label'], 'acne');
        expect(h['region'], 'right_cheek');
        expect(h['view_index'], 0);
      }
    });
  });
}
