import 'dart:convert';
import 'dart:io';

import 'package:afaskin/ml/fusion.dart';
import 'package:flutter_test/flutter_test.dart';

/// Keyakinan yang ditampilkan harus mendekati akurasi sebenarnya.
///
/// Sebelum ada `T_fusion`, angka yang dilihat pengguna jauh di bawah akurasi:
/// tipe kulit 67,2% untuk akurasi 82,7%, dan kondisi 41,4% untuk akurasi 82,4%
/// (ECE 0,410). Kalibrasi kedua memetakan ulang supaya angka itu jujur.
void main() {
  final cfg = jsonDecode(File('assets/ml/ml_config.json').readAsStringSync())
      as Map<String, dynamic>;
  final skin = (cfg['skin_type'] as Map).cast<String, dynamic>();
  final cond = (cfg['condition'] as Map).cast<String, dynamic>();
  final model = ((cond['models'] as Map)['ResNet50'] as Map).cast<String, dynamic>();

  test('T_fusion ada di konfigurasi', () {
    expect(skin['T_fusion'], isA<num>());
    expect(model['T_fusion'], isA<num>());
  });

  test('kalibrasi kedua menaikkan keyakinan, tidak mengubah argmax', () {
    // Distribusi lembek seperti hasil fusion sebelum kalibrasi kedua.
    final lembek = [0.45, 0.30, 0.25];
    final sesudah = calibrate(lembek, (model['T_fusion']! as num).toDouble());
    final urutSebelum = List.generate(lembek.length, (i) => i)
      ..sort((a, b) => lembek[b].compareTo(lembek[a]));
    final urutSesudah = List.generate(sesudah.length, (i) => i)
      ..sort((a, b) => sesudah[b].compareTo(sesudah[a]));
    expect(urutSesudah, urutSebelum, reason: 'urutan kelas tidak boleh berubah');
    expect(sesudah.first, greaterThan(lembek.first));
    expect(sesudah.reduce((a, b) => a + b), closeTo(1.0, 1e-9));
  });

  test('T_fusion < 1 berarti menajamkan, bukan melembekkan', () {
    final t = (model['T_fusion']! as num).toDouble();
    expect(t, lessThan(1.0));
    final p = calibrate([0.5, 0.3, 0.2], t);
    expect(p.first, greaterThan(0.5));
  });

  test('T_fusion = 1 tidak mengubah apa pun', () {
    final p = [0.6, 0.25, 0.15];
    final sama = calibrate(p, 1.0);
    for (var i = 0; i < p.length; i++) {
      expect(sama[i], closeTo(p[i], 1e-9));
    }
  });
}
