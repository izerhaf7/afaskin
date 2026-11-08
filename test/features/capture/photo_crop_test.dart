import 'dart:typed_data';
import 'dart:ui';

import 'package:afaskin/features/capture/photo_processing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

/// Gambar uji: gradien horizontal 200x300, supaya isi crop bisa diperiksa.
Uint8List _makeJpeg() {
  final im = img.Image(width: 200, height: 300);
  for (var y = 0; y < 300; y++) {
    for (var x = 0; x < 200; x++) {
      im.setPixelRgb(x, y, x, y % 256, 40);
    }
  }
  return img.encodeJpg(im, quality: 95);
}

void main() {
  test('cropPhoto mengambil area yang diminta dan mengembalikan JPEG', () {
    final src = _makeJpeg();
    final out = cropPhoto(
      src,
      const Rect.fromLTWH(20, 60, 160, 160),
      target: 320,
    );
    expect(out, isNotEmpty);
    final decoded = img.decodeJpg(out)!;
    // Keluaran persegi, diperbesar ke target karena crop 160 < 320.
    expect(decoded.width, 320);
    expect(decoded.height, 320);
  });

  test('cropPhoto tidak memperbesar kalau crop sudah besar', () {
    final out = cropPhoto(
      _makeJpeg(),
      const Rect.fromLTWH(0, 0, 200, 200),
      target: 120, // lebih kecil dari crop 200
    );
    final decoded = img.decodeJpg(out)!;
    expect(decoded.width, 200);
    expect(decoded.height, 200);
  });

  test('cropPhoto membatasi area yang keluar dari gambar', () {
    final out = cropPhoto(
      _makeJpeg(),
      const Rect.fromLTWH(150, 250, 400, 400), // melewati tepi kanan/bawah
      target: 120,
    );
    final decoded = img.decodeJpg(out)!;
    expect(decoded.width, greaterThan(0));
    expect(decoded.height, greaterThan(0));
    // Sisa area dari (150,250) ke tepi hanya 50x50, lalu diperbesar ke target
    // 120 karena lebih kecil. Yang penting: tidak melempar dan tetap persegi.
    expect(decoded.width, decoded.height);
    expect(decoded.width, 120);
  });

  test('cropPhoto melempar galat untuk byte yang bukan gambar', () {
    expect(
      () => cropPhoto(
        Uint8List.fromList([1, 2, 3]),
        const Rect.fromLTWH(0, 0, 10, 10),
      ),
      throwsA(isA<PhotoDecodeException>()),
    );
  });
}
