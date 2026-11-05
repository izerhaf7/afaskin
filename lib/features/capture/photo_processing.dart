import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Upload limits from the brief.
const int kMaxUploadSide = 1080;
const int kJpegQuality = 85;

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
