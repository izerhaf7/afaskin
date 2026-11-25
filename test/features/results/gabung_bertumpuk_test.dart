import 'package:afaskin/data/repositories/analysis_repository_local.dart';
import 'package:flutter_test/flutter_test.dart';

/// `gabungBertumpuk` dulu membaca kunci `view`, padahal spot ditulis dengan
/// kunci `view_index`. Akibatnya setiap analisis yang menemukan dua lesi atau
/// lebih melempar "Null check operator used on a null value" dan seluruh
/// analisis gagal dengan pesan "kesalahan saat menjalankan model". Wajah tanpa
/// lesi tetap "berhasil", jadi bug ini sulit terlihat.
///
/// Tes ini mengunci bentuk masukan yang sebenarnya dipakai aplikasi.
Map<String, Object> _spot({
  required double x,
  required double y,
  // 0,074 = sisi petak nyata (tile_rel 0,15 x lebar wajah relatif), dan di
  // bawah batas luas gabung 0,10 supaya satu petak bisa bergabung.
  double size = 0.074,
  String label = 'acne',
  String region = 'forehead',
  int viewIndex = 0,
}) => {
  'x': x,
  'y': y,
  'size': size,
  'label': label,
  'region': region,
  'view_index': viewIndex,
};

void main() {
  group('gabungBertumpuk', () {
    test('dua lesi berdekatan tidak melempar dan tetap membawa view_index', () {
      final hasil = gabungBertumpuk([
        _spot(x: 0.30, y: 0.30),
        _spot(x: 0.33, y: 0.32),
      ]);
      expect(hasil, hasLength(1));
      expect(hasil.first['view_index'], 0);
      expect(hasil.first['label'], 'acne');
      expect(hasil.first['region'], 'forehead');
    });

    test('beberapa petak yang menutupi satu lesi menyatu', () {
      // Sebaran pusat 0,024 + sisi petak 0,074 = 0,098, masih di bawah batas
      // 0,10, jadi ini satu lesi dan harus satu kotak.
      final hasil = gabungBertumpuk([
        for (var i = 0; i < 4; i++) _spot(x: 0.30 + i * 0.008, y: 0.30),
      ]);
      expect(hasil, hasLength(1));
      expect(hasil.first['support'], 4);
    });

    test('lesi jauh tetap terpisah', () {
      final hasil = gabungBertumpuk([
        _spot(x: 0.20, y: 0.20),
        _spot(x: 0.80, y: 0.80),
      ]);
      expect(hasil, hasLength(2));
    });

    test('foto samping tidak bercampur dengan foto depan', () {
      final hasil = gabungBertumpuk([
        _spot(x: 0.30, y: 0.30, viewIndex: 0),
        _spot(x: 0.31, y: 0.31, viewIndex: 1),
      ]);
      final views = hasil.map((h) => h['view_index']).toSet();
      expect(views, containsAll(<int>[0, 1]),
          reason: 'penanda view tidak boleh hilang atau tertukar');
    });

    test('kunci yang hilang tidak menggagalkan penggabungan', () {
      // Masukan cacat: tanpa region dan view_index. Dulu ini melempar.
      final cacat = <Map<String, Object>>[
        {'x': 0.4, 'y': 0.4, 'size': 0.1, 'label': 'acne'},
        {'x': 0.42, 'y': 0.41, 'size': 0.1, 'label': 'acne'},
      ];
      late List<Map<String, Object>> hasil;
      expect(() => hasil = gabungBertumpuk(cacat), returnsNormally);
      expect(hasil, hasLength(1));
      expect(hasil.first['view_index'], 0);
    });

    test('satu lesi dikembalikan apa adanya', () {
      final satu = [_spot(x: 0.5, y: 0.5)];
      expect(gabungBertumpuk(satu), same(satu));
    });

    test('kotak gabungan tidak melebar melebihi batas 0,45', () {
      final hasil = gabungBertumpuk([
        _spot(x: 0.10, y: 0.50, size: 0.30),
        _spot(x: 0.90, y: 0.50, size: 0.30),
      ]);
      for (final h in hasil) {
        expect(h['size']! as double, lessThanOrEqualTo(0.45));
      }
    });
  });
}
