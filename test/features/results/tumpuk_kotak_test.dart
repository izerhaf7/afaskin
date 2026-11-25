import 'package:afaskin/data/repositories/analysis_repository_local.dart';
import 'package:flutter_test/flutter_test.dart';

/// Keluhan: peta wajah penuh petak yang saling menumpuk sehingga terlihat
/// berantakan.
///
/// Penyebabnya `gabungBertumpuk` bekerja berantai: kelompok tumbuh dari satu
/// petak dan berhenti begitu sebarannya melewati batas luas. Dua kelompok yang
/// tumbuh dari titik berbeda bisa berakhir saling menimpa, karena tidak ada
/// aturan yang melarang hasil akhirnya bertumpuk.
///
/// Tes ini mengunci aturan: kotak hasil akhir tidak boleh saling menumpuk lebih
/// dari separuh luas kotak yang lebih kecil. Kotak yang berjauhan tetap terpisah.
Map<String, Object> _spot(
  double x,
  double y, {
  double size = 0.074,
  String label = 'acne',
  int view = 0,
}) =>
    {
      'x': x,
      'y': y,
      'size': size,
      'label': label,
      'region': 'right_cheek',
      'view_index': view,
    };

double _overlap(Map<String, Object> a, Map<String, Object> b) {
  final ax = (a['x']! as num).toDouble(), ay = (a['y']! as num).toDouble();
  final asz = (a['size']! as num).toDouble();
  final bx = (b['x']! as num).toDouble(), by = (b['y']! as num).toDouble();
  final bsz = (b['size']! as num).toDouble();
  final l = [ax - asz / 2, bx - bsz / 2].reduce((p, q) => p > q ? p : q);
  final t = [ay - asz / 2, by - bsz / 2].reduce((p, q) => p > q ? p : q);
  final r = [ax + asz / 2, bx + bsz / 2].reduce((p, q) => p < q ? p : q);
  final bo = [ay + asz / 2, by + bsz / 2].reduce((p, q) => p < q ? p : q);
  if (r <= l || bo <= t) return 0;
  final irisan = (r - l) * (bo - t);
  final kecil = asz * asz < bsz * bsz ? asz * asz : bsz * bsz;
  return irisan / kecil;
}

void main() {
  group('kotak lesi tidak menumpuk', () {
    test('kelompok berderet tidak menghasilkan kotak yang saling menimpa', () {
      // Deretan memanjang dua baris: tanpa aturan tumpang tindih, rantai
      // penggabungan memecahnya menjadi beberapa kotak yang saling menimpa.
      final spots = <Map<String, Object>>[
        for (var baris = 0; baris < 2; baris++)
          for (var i = 0; i < 12; i++)
            _spot(0.25 + i * 0.045, 0.40 + baris * 0.02),
      ];
      final hasil = gabungBertumpuk(spots);
      for (var i = 0; i < hasil.length; i++) {
        for (var j = i + 1; j < hasil.length; j++) {
          expect(_overlap(hasil[i], hasil[j]), lessThan(0.5),
              reason: 'kotak $i dan $j saling menumpuk '
                  '${_overlap(hasil[i], hasil[j]).toStringAsFixed(2)}');
        }
      }
    });

    test('petak bertumpuk rapat di satu titik jadi satu kotak', () {
      final spots = <Map<String, Object>>[
        for (var i = 0; i < 9; i++)
          _spot(0.500 + (i % 3) * 0.042, 0.300 + (i ~/ 3) * 0.042),
      ];
      final hasil = gabungBertumpuk(spots);
      expect(hasil, hasLength(1));
      expect(hasil.first['support'], 9);
    });

    test('lesi berjauhan tetap kotak terpisah', () {
      final hasil = gabungBertumpuk([
        _spot(0.25, 0.35),
        _spot(0.75, 0.65),
      ]);
      expect(hasil, hasLength(2));
      expect(_overlap(hasil[0], hasil[1]), 0);
    });

    test('kondisi berbeda tidak pernah disatukan', () {
      final hasil = gabungBertumpuk([
        _spot(0.50, 0.50, label: 'acne'),
        _spot(0.52, 0.52, label: 'scar'),
      ]);
      expect(hasil, hasLength(2));
      expect(hasil.map((h) => h['label']).toSet(), {'acne', 'scar'});
    });

    test('foto berbeda tidak pernah disatukan', () {
      final hasil = gabungBertumpuk([
        _spot(0.50, 0.50, view: 0),
        _spot(0.52, 0.52, view: 1),
      ]);
      expect(hasil, hasLength(2));
      expect(hasil.map((h) => h['view_index']).toSet(), {0, 1});
    });

    test('ukuran tetap masuk akal dan tidak menelan seluruh peta', () {
      final spots = <Map<String, Object>>[
        for (var i = 0; i < 40; i++) _spot(0.2 + (i % 8) * 0.03, 0.3 + (i ~/ 8) * 0.03),
      ];
      for (final h in gabungBertumpuk(spots)) {
        final s = (h['size']! as num).toDouble();
        expect(s, greaterThan(0));
        expect(s, lessThanOrEqualTo(0.45));
      }
    });

    test('satu petak tidak diubah', () {
      final hasil = gabungBertumpuk([_spot(0.4, 0.6)]);
      expect(hasil, hasLength(1));
      expect(hasil.first['size'], 0.074);
    });
  });
}
