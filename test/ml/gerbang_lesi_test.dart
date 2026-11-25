import 'package:afaskin/ml/fusion.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lesi di dahi hanya menempati beberapa petak dari sekitar seratus. Rata-rata
/// seluruh petak jadi kecil walau bukti terkuatnya tinggi, sehingga syarat
/// "rata-rata minimal" membuang lesi yang sebenarnya terlihat jelas.
///
/// Diukur pada 25 wajah berlesi di bagian atas: aturan lama meloloskan 4,
/// tanpa syarat rata-rata 15. Pada 235 wajah berjerawat vs 86 wajah bersih,
/// syarat itu menahan 6 wajah berjerawat dan 0 wajah bersih.
void main() {
  group('layakTampil', () {
    test('bukti visual kuat menampilkan kondisi meski rata-rata rendah', () {
      // Kasus nyata: dahi dengan bukti 0,778 tetapi rata-rata 0,056.
      expect(
        layakTampil(buktiVisual: 0.778, ambangVisual: 0.34, minRata: 0.12),
        isTrue,
        reason: 'lesi dahi seperti ini sebelumnya hilang',
      );
    });

    test('rata-rata tinggi tidak menolong bila bukti visual lemah', () {
      expect(
        layakTampil(buktiVisual: 0.20, ambangVisual: 0.34, minRata: 0.12),
        isFalse,
      );
    });

    test('bukti tepat di ambang tetap ditampilkan', () {
      expect(
        layakTampil(buktiVisual: 0.34, ambangVisual: 0.34),
        isTrue,
      );
    });

    test('ambang nol atau negatif tidak pernah menampilkan', () {
      expect(layakTampil(buktiVisual: 0.9, ambangVisual: 0), isFalse);
      expect(layakTampil(buktiVisual: 0.9, ambangVisual: -1), isFalse);
    });

    test('kelas dengan ambang rendah (Scars 0,16) tetap ditampilkan', () {
      expect(layakTampil(buktiVisual: 0.17, ambangVisual: 0.16), isTrue);
      expect(layakTampil(buktiVisual: 0.15, ambangVisual: 0.16), isFalse);
    });
  });

  test('topKMean mengambil petak terkuat, bukan rata-rata semua', () {
    // Lesi terlihat di 4 petak dari 100, sisanya kulit bersih. Inilah bentuk
    // nyata lesi dahi: rata-rata tersapu 96 petak bersih, top-4 tetap kuat.
    final tiles = <List<double>>[
      [0.96, 0.04],
      [0.80, 0.20],
      [0.70, 0.30],
      [0.60, 0.40],
      for (var i = 0; i < 96; i++) [0.01, 0.99],
    ];
    final mean = tiles.map((t) => t[0]).reduce((a, b) => a + b) / tiles.length;
    expect(mean, lessThan(0.12), reason: 'rata-rata tersapu petak bersih');
    // top-4 = (0,96 + 0,80 + 0,70 + 0,60) / 4 = 0,765
    expect(topKMean(tiles, 0, 4), closeTo(0.765, 0.001));
  });
}
