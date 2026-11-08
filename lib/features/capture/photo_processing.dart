import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:image/image.dart' as img;

/// Photo limits. Analysis runs on the device, so the photo is kept large
/// enough for skin detail (skin patches are ~15% of the face width).
const int kMaxUploadSide = 1600;
const int kJpegQuality = 92;

class PhotoDecodeException implements Exception {
  const PhotoDecodeException();
}

/// Prepares a photo for upload: applies the EXIF orientation to the pixels,
/// drops all metadata (EXIF, GPS, ICC), resizes so the longest side is at
/// most [maxSide], and re-encodes as JPEG at [quality].
///
/// Pure and synchronous; call [preparePhotoInBackground] from the UI.
Uint8List preparePhotoForUpload(
  Uint8List input, {
  int maxSide = kMaxUploadSide,
  int quality = kJpegQuality,
}) {
  img.Image? decoded;
  try {
    decoded = img.decodeImage(input);
  } on Object {
    decoded = null; // Corrupt or unsupported file.
  }
  if (decoded == null) throw const PhotoDecodeException();

  // Rotate pixels to match EXIF orientation *before* the EXIF is dropped,
  // otherwise portrait photos would arrive sideways.
  var image = img.bakeOrientation(decoded);

  final longest = image.width > image.height ? image.width : image.height;
  if (longest > maxSide) {
    image = image.width >= image.height
        ? img.copyResize(
            image,
            width: maxSide,
            interpolation: img.Interpolation.average,
          )
        : img.copyResize(
            image,
            height: maxSide,
            interpolation: img.Interpolation.average,
          );
  }

  // Strip every metadata block so nothing (location, device) is uploaded.
  image
    ..exif = img.ExifData()
    ..iccProfile = null
    ..textData = null;

  return img.encodeJpg(image, quality: quality);
}

/// Runs [preparePhotoForUpload] off the UI thread.
Future<Uint8List> preparePhotoInBackground(Uint8List input) =>
    Isolate.run(() => preparePhotoForUpload(input));

/// Crop persegi pada foto yang sudah disiapkan: mengambil bagian yang dipilih
/// pengguna di layar "Atur posisi", lalu menghapus metadata lagi.
///
/// [rect] dalam piksel gambar, [target] sisi keluaran (mis. 1200 untuk foto
/// wajah 3 sudut). Crop dilakukan setelah [img.bakeOrientation] sehingga
/// koordinatnya sama dengan yang terlihat di layar.
Uint8List cropPhoto(
  Uint8List input,
  Rect rect, {
  int target = 1200,
  int quality = kJpegQuality,
}) {
  final decoded = img.decodeImage(input);
  if (decoded == null) throw const PhotoDecodeException();
  var image = img.bakeOrientation(decoded);

  final x = rect.left.round().clamp(0, image.width - 1);
  final y = rect.top.round().clamp(0, image.height - 1);
  final w = rect.width.round().clamp(1, image.width - x);
  final h = rect.height.round().clamp(1, image.height - y);
  image = img.copyCrop(image, x: x, y: y, width: w, height: h);

  // Keluaran persegi: model kondisi memotong patch dari area wajah, jadi
  // resolusi wajah yang cukup lebih penting daripada mempertahankan rasio.
  if (image.width < target) {
    image = img.copyResize(
      image,
      width: target,
      height: target,
      interpolation: img.Interpolation.cubic,
    );
  }

  image
    ..exif = img.ExifData()
    ..iccProfile = null
    ..textData = null;

  return img.encodeJpg(image, quality: quality);
}

/// Runs [cropPhoto] off the UI thread.
Future<Uint8List> cropPhotoInBackground(Uint8List input, Rect rect, {int target = 1200}) =>
    Isolate.run(() => cropPhoto(input, rect, target: target));

