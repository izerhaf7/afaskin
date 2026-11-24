import 'package:afaskin/data/repositories/analysis_repository_local.dart';
import 'package:flutter_test/flutter_test.dart';

/// Analisis pernah gagal dengan pesan "terjadi kesalahan saat menjalankan model
/// (StateError)" tanpa penjelasan. Dua hal yang diuji di sini: setiap sebab
/// punya kalimat yang bisa ditindaklanjuti, dan sebab yang tidak dikenal pun
/// tidak pernah mengembalikan teks kosong atau "null".
void main() {
  group('localFailureCause', () {
    test('wajah tidak terdeteksi', () {
      expect(
        localFailureCause(StateError('no_face: 0 faces')),
        contains('wajah tidak terdeteksi'),
      );
    });

    test('tidak ada area kulit yang bisa dinilai', () {
      final m = localFailureCause(StateError('no_tiles: tidak ada area'));
      expect(m, contains('area kulit'));
      expect(m, contains('foto ulang'),
          reason: 'pengguna harus tahu langkah berikutnya');
    });

    test('model tidak selesai menghitung', () {
      for (final msg in [
        'model tidak memberi keluaran untuk 12 petak',
        'keluaran model tidak bulat per petak (30 nilai untuk 4 petak)',
      ]) {
        final m = localFailureCause(StateError(msg));
        expect(m, contains('analisis ulang'));
        expect(m, isNot(contains('StateError')),
            reason: 'nama kelas exception tidak berguna bagi pengguna');
      }
    });

    test('StateError lain tetap menyebut isi pesannya', () {
      expect(
        localFailureCause(StateError('model berhenti')),
        contains('model berhenti'),
      );
    });

    test('RangeError dan TypeError punya kalimat sendiri', () {
      expect(localFailureCause(RangeError('x')), contains('tidak lengkap'));
      expect(localFailureCause(TypeError()), contains('tidak dikenali'));
    });

    test('sebab yang tidak dikenal tetap memberi langkah berikutnya', () {
      final m = localFailureCause(Exception('sesuatu'));
      expect(m, contains('kesalahan saat menjalankan model'));
      expect(m, contains('Coba analisis ulang'));
      expect(m.trim(), isNotEmpty);
    });

    test('tidak pernah mengembalikan teks kosong', () {
      final errors = <Object>[
        StateError(''),
        RangeError.range(3, 0, 1),
        TypeError(),
        ArgumentError('x'),
        Exception(),
      ];
      for (final e in errors) {
        expect(localFailureCause(e).trim(), isNotEmpty, reason: '$e');
      }
    });
  });
}
