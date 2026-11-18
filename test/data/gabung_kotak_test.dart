import 'package:afaskin/data/repositories/analysis_repository_local.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object> _k(double x, double y, {double size = 0.15, String label = 'Acne'}) => {
  'x': x,
  'y': y,
  'size': size,
  'label': label,
  'region': 'forehead',
  'view': 0,
};

/// Patch dipotong dengan stride separuh patch, jadi satu lesi memunculkan
/// beberapa kotak yang saling menimpa. Tanpa penggabungan, peta wajah
/// menampilkan tumpukan garis dan warna kondisi sulit dibedakan.
void main() {
  test('dua kotak berdekatan digabung jadi satu', () {
    final hasil = gabungBertumpuk([_k(0.50, 0.30), _k(0.55, 0.32)]);
    expect(hasil.length, 1);
    expect(hasil.first['x']! as double, closeTo(0.525, 1e-9));
    expect(hasil.first['y']! as double, closeTo(0.31, 1e-9));
  });

  test('kotak berjauhan tidak digabung', () {
    final hasil = gabungBertumpuk([_k(0.20, 0.20), _k(0.80, 0.80)]);
    expect(hasil.length, 2);
  });

  test('tiga kotak berderet menjadi satu kelompok', () {
    final hasil = gabungBertumpuk([
      _k(0.30, 0.30),
      _k(0.35, 0.30),
      _k(0.40, 0.30),
    ]);
    expect(hasil.length, 1);
    expect(hasil.first['x']! as double, closeTo(0.35, 1e-9));
  });

  test('dua kelompok terpisah tetap dua', () {
    final hasil = gabungBertumpuk([
      _k(0.20, 0.20),
      _k(0.25, 0.20),
      _k(0.75, 0.70),
      _k(0.80, 0.70),
    ]);
    expect(hasil.length, 2);
  });

  test('dua kotak yang tepinya masih bersinggungan ikut digabung', () {
    // Jarak 0,9 x sisi kotak: secara visual kedua kotak masih bertumpuk,
    // jadi harus menyatu supaya peta wajah tidak menampilkan garis ganda.
    final hasil = gabungBertumpuk([_k(0.50, 0.30), _k(0.635, 0.30)]);
    expect(hasil.length, 1);
  });

  test('satu kotak dikembalikan apa adanya', () {
    final hasil = gabungBertumpuk([_k(0.5, 0.5)]);
    expect(hasil.length, 1);
    expect(hasil.first['x'], 0.5);
  });

  test('daftar kosong aman', () {
    expect(gabungBertumpuk([]), isEmpty);
  });
}
