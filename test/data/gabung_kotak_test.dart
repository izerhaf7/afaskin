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

  test('dua kotak yang pusatnya berdekatan digabung jadi satu', () {
    // Jarak 0,4 x sisi kotak: kedua kotak masih saling menimpa berat,
    // jadi harus menyatu supaya peta wajah tidak menampilkan garis ganda.
    final hasil = gabungBertumpuk([_k(0.50, 0.30), _k(0.56, 0.30)]);
    expect(hasil.length, 1);
  });

  test('kotak yang bertumpuk tepi tetap menyatu, tetapi rantai panjang dipisah', () {
    // Dua kotak berjarak 0,9 x sisi memang bertumpuk, jadi menyatu: itu satu
    // lesi yang muncul di dua petak, dan pengguna memintanya sebagai satu kotak.
    //
    // Kekhawatiran lama — rangkaian kotak menyatu jadi satu area raksasa —
    // sekarang ditangani batas sebaran, bukan ambang jarak. Karena itu yang
    // diuji di sini adalah rantainya, bukan pasangan tunggalnya.
    final dua = gabungBertumpuk([_k(0.50, 0.30), _k(0.635, 0.30)]);
    expect(dua.length, 1);

    // Enam kotak berderet rapat: kalau menyatu semua, hasilnya satu kotak
    // selebar 0,9 lebar foto dan lesi lain tidak terpetakan.
    final rantai = gabungBertumpuk([
      for (var i = 0; i < 6; i++) _k(0.20 + i * 0.09, 0.30),
    ]);
    expect(rantai.length, greaterThan(1),
        reason: 'rantai panjang harus terpecah, bukan jadi satu kotak raksasa');
    for (final h in rantai) {
      expect(h['size']! as double, lessThanOrEqualTo(0.45));
    }
  });

  test('kotak gabungan membesar mengikuti luas lesi', () {
    // Tiga patch berderet: kotak hasil harus lebih lebar dari satu patch,
    // supaya lesi luas tampil seluas areanya, bukan sebagai satu titik.
    final hasil = gabungBertumpuk([
      _k(0.30, 0.30),
      _k(0.35, 0.30),
      _k(0.40, 0.30),
    ]);
    expect(hasil.length, 1);
    expect(hasil.first['size']! as double, greaterThan(0.15));
  });

  test('satu area tidak menelan seluruh peta', () {
    // Patch yang tersebar di seluruh wajah tetap menghasilkan beberapa kotak,
    // bukan satu kotak raksasa.
    final hasil = gabungBertumpuk([
      for (var i = 0; i < 6; i++)
        for (var j = 0; j < 6; j++) _k(0.15 + i * 0.12, 0.15 + j * 0.12),
    ]);
    expect(hasil.length, greaterThan(3));
    for (final h in hasil) {
      expect(h['size']! as double, lessThanOrEqualTo(0.45));
    }
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
