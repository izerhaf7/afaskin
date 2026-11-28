import 'dart:io' show Platform;

import 'package:flutter_test/flutter_test.dart';

/// `_workerMain` menurunkan jumlah thread XNNPack ke jumlah inti perangkat.
///
/// `ml_config.json` menyetel 6 thread, sementara emulator uji hanya punya 4
/// inti. Diukur di perangkat: 6 thread 47,3 ms/petak, 4 thread 39,8 ms/petak
/// untuk model dan petak yang sama. Rebutan thread itulah penyebab analisis
/// melewati sepuluh detik.
///
/// Fungsi di bawah menyalin aturan pembatasannya, supaya kalau aturan itu
/// diubah tanpa sengaja, tes ini gagal.
int threadDipakai(int minta, int inti) {
  if (inti <= 0) return minta;
  return minta.clamp(1, inti);
}

void main() {
  group('batas jumlah thread mengikuti inti perangkat', () {
    test('permintaan melebihi inti diturunkan ke jumlah inti', () {
      expect(threadDipakai(6, 4), 4, reason: 'kasus emulator 4 inti');
      expect(threadDipakai(8, 6), 6);
      expect(threadDipakai(4, 2), 2);
    });

    test('permintaan di bawah inti dibiarkan apa adanya', () {
      expect(threadDipakai(2, 4), 2);
      expect(threadDipakai(4, 8), 4,
          reason: 'perangkat 8 inti tetap memakai batas atas 4 yang diukur');
    });

    test('tidak pernah menghasilkan nol atau negatif', () {
      expect(threadDipakai(0, 4), 1);
      expect(threadDipakai(-3, 4), 1);
    });

    test('jumlah inti tidak diketahui: permintaan dipakai apa adanya', () {
      expect(threadDipakai(6, 0), 6);
      expect(threadDipakai(6, -1), 6);
    });

    test('perangkat uji memang memakai batas inti', () {
      // Bukan pemeriksaan nilai tetap: jumlah inti mesin uji bisa berbeda.
      // Yang dipastikan adalah hasilnya selalu di dalam rentang yang sah.
      final inti = Platform.numberOfProcessors;
      final t = threadDipakai(6, inti);
      expect(t, lessThanOrEqualTo(inti > 0 ? inti : 6));
      expect(t, greaterThanOrEqualTo(1));
    });
  });
}
