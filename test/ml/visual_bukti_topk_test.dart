import 'package:afaskin/ml/fusion.dart';
import 'package:flutter_test/flutter_test.dart';

/// Bukti visual memakai rata-rata k patch terkuat, bukan jumlah patch yang
/// melewati ambang.
///
/// Aturan lama membuang lesi selfie: lesi hanya terlihat di 4-5 patch dari 26
/// dan keyakinannya rendah, jadi jumlah patch di atas ambang tidak pernah
/// tercapai. Rata-rata top-k tetap menangkap sinyal itu.
void main() {
  const kelas = ['Acne', 'Scars', 'Clear'];

  /// [n] patch, tiap patch [p] untuk kelas ke-0.
  List<List<double>> patch(int n, double p, {int kelasIdx = 0}) => [
    for (var i = 0; i < n; i++)
      [
        for (var k = 0; k < kelas.length; k++)
          k == kelasIdx ? p : (1 - p) / (kelas.length - 1),
      ],
  ];

  test('lesi lemah di banyak patch tetap terdeteksi', () {
    // 26 patch, hanya 5 yang melihat Acne dengan keyakinan sedang.
    final tiles = [
      for (var i = 0; i < 21; i++) [0.05, 0.02, 0.93],
      for (var i = 0; i < 5; i++) [0.55, 0.20, 0.25],
    ];
    final ev = visualEvidence(tiles, kelas, conf: 0.35);
    // Aturan lama: 5 patch >= 0,35 -> lolos kalau min 3.
    expect(ev['Acne']!.count, 5);
    // Rata-rata top-4 = 0,55 -> lolos ambang 0,38.
    expect(topKMean(tiles, 0, 4), closeTo(0.55, 1e-9));
  });

  test('patch yang semuanya lemah tidak lolos', () {
    final tiles = [
      for (var i = 0; i < 26; i++) [0.20, 0.10, 0.70],
    ];
    // Rata-rata top-4 = 0,20 -> di bawah ambang 0,38.
    expect(topKMean(tiles, 0, 4), closeTo(0.20, 1e-9));
  });

  test('satu patch sangat yakin tidak cukup', () {
    final tiles = [
      for (var i = 0; i < 25; i++) [0.02, 0.01, 0.97],
      [0.95, 0.03, 0.02],
    ];
    // Rata-rata top-4 = (0,95 + 0,02*3)/4 = 0,2525 -> di bawah 0,38.
    expect(topKMean(tiles, 0, 4), lessThan(0.38));
  });

  test('k lebih besar dari jumlah patch tidak error', () {
    final tiles = [
      [0.6, 0.2, 0.2],
      [0.5, 0.3, 0.2],
    ];
    expect(topKMean(tiles, 0, 10), closeTo(0.55, 1e-9));
  });

  test('indeks kelas di luar jangkauan menghasilkan nol', () {
    final tiles = [
      [0.6, 0.4],
    ];
    expect(topKMean(tiles, 5, 4), 0.0);
  });

  test('daftar kosong menghasilkan nol', () {
    expect(topKMean(<List<double>>[], 0, 4), 0.0);
  });
}
