import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:afaskin/features/capture/photo_processing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

/// Keluhan lama: "gallery crop 320×320 belum diperbaiki". Saat diperiksa, sisi
/// keluaran ternyata ditentukan pemanggil (1200 px), bukan 320. Yang benar-benar
/// salah: `cropPhoto` hanya MEMPERBESAR bila gambar lebih kecil dari target dan
/// tidak pernah memperkecil. Foto galeri 4000 px keluar sebagai crop 2000 px,
/// padahal pemanggil meminta 1200. Petak yang dinilai model hanya 224 px, jadi
/// piksel ekstra itu tidak menambah informasi, hanya memperlambat praproses dan
/// inferensi di HP.
Uint8List _foto(int w, int h) {
  final im = img.Image(width: w, height: h);
  img.fill(im, color: img.ColorRgb8(200, 180, 165));
  return Uint8List.fromList(img.encodeJpg(im, quality: 90));
}

({int width, int height}) _ukuran(Uint8List b) {
  final d = img.decodeImage(b)!;
  return (width: d.width, height: d.height);
}

void main() {
  group('cropPhoto menghormati target', () {
    test('foto besar diperkecil ke target, bukan dibiarkan', () {
      final masuk = _foto(1600, 1600);
      final keluar = cropPhoto(
        masuk,
        const Rect.fromLTWH(0, 0, 800, 800),
        target: 600,
      );
      final u = _ukuran(keluar);
      expect(u.width, 600, reason: 'lebar harus dipaksa ke target');
      expect(u.height, 600, reason: 'keluaran harus persegi');
    });

    test('foto kecil diperbesar ke target', () {
      final masuk = _foto(400, 400);
      final keluar = cropPhoto(
        masuk,
        const Rect.fromLTWH(0, 0, 300, 300),
        target: 900,
      );
      final u = _ukuran(keluar);
      expect(u.width, 900);
      expect(u.height, 900);
    });

    test('crop sudah seukuran target tidak diubah ukurannya', () {
      final masuk = _foto(1200, 1200);
      final keluar = cropPhoto(
        masuk,
        const Rect.fromLTWH(100, 100, 800, 800),
        target: 800,
      );
      final u = _ukuran(keluar);
      expect(u.width, 800);
      expect(u.height, 800);
    });

    test('crop di tepi kanan-bawah tidak melewati batas gambar', () {
      final masuk = _foto(1000, 800);
      final keluar = cropPhoto(
        masuk,
        const Rect.fromLTWH(900, 700, 400, 400),
        target: 400,
      );
      final u = _ukuran(keluar);
      expect(u.width, 400);
      expect(u.height, 400);
    });

    test('metadata dibuang dari hasil', () {
      final keluar = cropPhoto(
        _foto(800, 800),
        const Rect.fromLTWH(0, 0, 700, 700),
        target: 500,
      );
      final d = img.decodeImage(keluar)!;
      expect(d.exif, isNotNull);
      expect(d.exif.imageIfd.isEmpty, isTrue,
          reason: 'EXIF harus kosong pada foto yang dikirim ke model');
    });
  });
}
