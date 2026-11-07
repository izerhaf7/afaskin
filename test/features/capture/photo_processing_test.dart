import 'dart:typed_data';

import 'package:afaskin/features/capture/photo_processing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('resizes, applies orientation, strips EXIF, JPEG output', () {
    // 2000x1500 landscape pixels with EXIF orientation 6 (rotate 90 CW) and
    // a GPS tag, like a phone photo taken in portrait.
    final src = img.Image(width: 2000, height: 1500)
      ..exif.imageIfd.orientation = 6
      ..exif.gpsIfd['GPSLatitudeRef'] = img.IfdValueAscii('S');
    img.fill(src, color: img.ColorRgb8(200, 150, 120));
    final input = img.encodeJpg(src);
    expect(img.decodeJpg(input)!.exif.gpsIfd.isEmpty, isFalse);

    final out = preparePhotoForUpload(input);
    final decoded = img.decodeJpg(out)!;

    // Portrait after orientation is applied; longest side capped at 1600.
    expect(decoded.height, 1600);
    expect(decoded.width, 1200);
    // No metadata left.
    expect(decoded.exif.gpsIfd.isEmpty, isTrue);
    expect(decoded.exif.imageIfd.orientation, anyOf(isNull, 1));
    expect(decoded.exif.isEmpty, isTrue);
    // JPEG magic bytes.
    expect(out.sublist(0, 2), [0xFF, 0xD8]);
  });

  test('small images are not upscaled', () {
    final src = img.Image(width: 640, height: 480);
    final out = img.decodeJpg(preparePhotoForUpload(img.encodePng(src)))!;
    expect((out.width, out.height), (640, 480));
  });

  test('garbage input throws PhotoDecodeException', () {
    expect(
      () => preparePhotoForUpload(Uint8List.fromList([1, 2, 3, 4, 5])),
      throwsA(isA<PhotoDecodeException>()),
    );
  });
}
