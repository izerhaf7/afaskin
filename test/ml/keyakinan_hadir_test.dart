import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:afaskin/ml/fusion.dart';
import 'package:flutter_test/flutter_test.dart';

/// Keyakinan yang tampil harus menjawab "seberapa yakin aplikasi kondisi ini
/// ADA", bukan "berapa porsi kelas ini di dalam distribusi 10 kelas".
///
/// Perbedaan itu bukan istilah: dulu, pada wajah yang jelas berjerawat, jerawat
/// tampil 13% hanya karena bekas jerawat mengambil porsi lebih dulu. Sekarang
/// tiap kondisi dinilai sendiri-sendiri.
Map<String, dynamic> _cfg() {
  final c = jsonDecode(
        File('assets/ml/ml_config.json').readAsStringSync(),
      )
      as Map<String, dynamic>;
  return (c['condition']['models']['ResNet50']['presence'] as Map)
      .cast<String, dynamic>();
}

List<String> _classes() {
  final c =
      jsonDecode(File('assets/ml/ml_config.json').readAsStringSync())
          as Map<String, dynamic>;
  return (c['condition']['classes'] as List).cast<String>();
}

double _sig(double z) => 1 / (1 + math.exp(-z));

/// Patch sintetis: setiap patch memberi [p] untuk setiap kelas kondisi.
List<List<double>> _tiles(int n, double p) =>
    [for (var i = 0; i < n; i++) [for (var j = 0; j < 10; j++) p]];

void main() {
  test('bukti kuat -> keyakinan tinggi', () {
    final pr = presenceProbs(_tiles(20, 0.58), _classes(), _cfg());
    expect(pr['Acne']! * 100, greaterThan(85));
    expect(pr['Acne']! * 100, lessThan(100));
  });

  test('tidak pernah mengklaim 100% yakin', () {
    // Bukti sangat kuat pun tidak boleh tampil 100%: model tidak pernah pasti.
    final pr = presenceProbs(_tiles(20, 0.999), _classes(), _cfg());
    for (final e in pr.entries) {
      expect(e.value, lessThanOrEqualTo(0.99), reason: '${e.key} melebihi 99%');
      expect(e.value, greaterThanOrEqualTo(0.01), reason: '${e.key} di bawah 1%');
    }
  });

  test('bukti lemah -> keyakinan rendah', () {
    final pr = presenceProbs(_tiles(20, 0.02), _classes(), _cfg());
    for (final c in ['Acne', 'Scars', 'Blackhead', 'Papular']) {
      expect(pr[c]! * 100, lessThan(15), reason: '$c tidak boleh yakin');
    }
  });

  test('dua kondisi bisa sama-sama tinggi, tidak berebut 100%', () {
    // Ini inti perbaikannya: pada distribusi porsi, dua kondisi yang sama-sama
    // ada akan saling menekan. Di sini keduanya boleh tinggi sekaligus.
    final pr = presenceProbs(_tiles(20, 0.58), _classes(), _cfg());
    expect(pr['Acne']! * 100, greaterThan(70));
    expect(pr['Scars']! * 100, greaterThan(60));
    // Totalnya tidak dipaksa 1.
    expect(
      pr.values.reduce((a, b) => a + b),
      greaterThan(1.5),
      reason: 'keyakinan kehadiran bukan distribusi yang jumlahnya 1',
    );
  });

  test('Clear tidak dihitung sebagai kondisi', () {
    final pr = presenceProbs(_tiles(20, 0.9), _classes(), _cfg());
    expect(pr.containsKey('Clear'), isFalse);
  });

  test('cocok dengan hitungan Python pada bukti 0,58', () {
    // Angka acuan dari pipeline Python (kalibrasi_hadir), toleransi 0,5 poin.
    final pr = presenceProbs(_tiles(20, 0.58), _classes(), _cfg());
    final cfg = _cfg();
    const j = 0; // Acne
    final x = 0.58;
    final z = math.log(x / (1 - x));
    final acuan = _sig((cfg['a'][j] as num) * z + (cfg['b'][j] as num));
    expect((pr['Acne']! - acuan).abs(), lessThan(0.005));
  });

  test('daftar patch kosong aman', () {
    expect(presenceProbs(const [], _classes(), _cfg()), isEmpty);
  });

  test('config kosong aman (tidak melempar)', () {
    expect(presenceProbs(_tiles(5, 0.5), _classes(), const {}), isEmpty);
  });

  test('top_k dihormati: butuh beberapa patch, satu patch liar tidak cukup', () {
    // Satu patch sangat yakin, sisanya nol. Dengan top_k 3, bukti = (0,99 +
    // 0,01 + 0,01)/3 = 0,337, jadi keyakinan harus jauh di bawah kasus tiga
    // patch yang benar-benar mendukung (0,58 -> 94%).
    final liar = [
      [0.99, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
      for (var i = 0; i < 19; i++)
        [0.01, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    ];
    final tiga = [
      for (var i = 0; i < 3; i++)
        [0.58, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
      for (var i = 0; i < 17; i++)
        [0.02, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    ];
    final a = presenceProbs(liar, _classes(), _cfg())['Acne']!;
    final b = presenceProbs(tiga, _classes(), _cfg())['Acne']!;
    expect(
      a,
      lessThan(b - 0.1),
      reason: 'satu patch liar harus lebih lemah dari tiga patch yang sepakat',
    );
    expect(b * 100, greaterThan(85));
  });
}
