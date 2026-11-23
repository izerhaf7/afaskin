import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart'
    show
        FaceDetector,
        FaceDetectorMode,
        FaceDetectorOptions,
        InputImage;
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:image/image.dart' as img;

/// 468 titik wajah dari ML Kit Face Mesh (on-device, Android). Topologinya sama
/// dengan MediaPipe Face Mesh yang dipakai saat training (notebook 03).
///
/// Face Mesh tidak punya opsi ukuran wajah minimum, dan ia menolak wajah yang
/// mengisi hampir seluruh frame, wajah yang terpotong tepi, atau wajah kecil di
/// foto beresolusi tinggi. Diukur pada fixture di perangkat: foto selfie yang
/// jelas terlihat tetap menghasilkan nol mesh. Karena itu deteksi dua tahap:
///
///  1. coba Face Mesh pada foto apa adanya;
///  2. kalau kosong, pakai Face Detector untuk menemukan kotak wajah, potong
///     dengan margin, perbesar ke ukuran yang nyaman, lalu jalankan Face Mesh
///     pada potongan itu. Titik dipetakan balik ke koordinat foto asli, jadi
///     seluruh pipeline di hilir (masker ROI, patch, jarak) tidak berubah.
class FaceMeshService {
  final FaceMeshDetector _meshDetector =
      FaceMeshDetector(option: FaceMeshDetectorOptions.faceMesh);

  /// Hanya penolong tahap 2. Ambang dibuat longgar supaya kasus yang ditolak
  /// Face Mesh masih punya peluang.
  final FaceDetector _boxDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      minFaceSize: 0.05,
    ),
  );

  /// Ukuran keluaran potongan wajah. Face Mesh menolak crop persegi 512x512
  /// walau wajahnya jelas: diukur di perangkat, Face Detector menemukan kotak
  /// 538x732 pada foto yang sama tetapi Face Mesh mengembalikan nol titik untuk
  /// crop 512x512. Aspek potret 3:4 dan margin lebar membuatnya terdeteksi.
  static const int _retryWidth = 480;
  static const int _retryHeight = 640;

  /// Margin di sekitar kotak wajah supaya dahi, dagu, dan sisi wajah tidak
  /// menyentuh tepi frame. Wajah yang menyentuh tepi ditolak Face Mesh.
  static const double _boxMargin = 0.55;

  /// Titik dalam koordinat piksel [jpeg]. `points` null kalau tidak ada wajah.
  Future<({int faces, List<(double, double)>? points})> detect(
    Uint8List jpeg,
  ) async {
    final trace = <String, Object?>{'bytes': jpeg.length};
    try {
      final direct = await _mesh(jpeg);
      trace['direct'] = direct != null;
      if (direct != null) {
        _trace(trace);
        return (faces: 1, points: direct);
      }

      final box = await _detectBox(jpeg);
      trace['box'] =
          box == null ? null : [box.left, box.top, box.width, box.height];
      if (box != null) {
        final cropped = await _cropAndScale(jpeg, box);
        trace['cropped'] = cropped == null
            ? null
            : [cropped.offsetX, cropped.offsetY, cropped.scaleX, cropped.scaleY, cropped.bytes.length];
        if (cropped != null) {
          final pts = await _mesh(cropped.bytes);
          trace['retry'] = pts != null;
          if (pts != null) {
            _trace(trace);
            return (
              faces: 1,
              points: [
                for (final (x, y) in pts)
                  (
                    cropped.offsetX + x / cropped.scaleX,
                    cropped.offsetY + y / cropped.scaleY,
                  ),
              ],
            );
          }
        }
      }
      trace['result'] = 'no face';
      _trace(trace);
      return (faces: 0, points: null);
    } on Object catch (e) {
      trace['error'] = '$e';
      _trace(trace);
      rethrow;
    }
  }

  /// Hanya aktif saat ML_DEBUG: menulis ringkasan percobaan deteksi.
  void _trace(Map<String, Object?> data) {
    if (!const bool.fromEnvironment('ML_DEBUG')) return;
    debugPrint('AFASkin MESH_TRACE: ${jsonEncode(data)}');
  }

  Future<List<(double, double)>?> _mesh(Uint8List jpeg) async {
    final file = _tempFile();
    try {
      await file.writeAsBytes(jpeg, flush: true);
      final meshes = await _meshDetector.processImage(
        InputImage.fromFilePath(file.path),
      );
      if (meshes.isEmpty) return null;
      final pts = [...meshes.first.points]
        ..sort((a, b) => a.index.compareTo(b.index));
      if (pts.length < 468) return null;
      return [for (final p in pts) (p.x, p.y)];
    } finally {
      await _delete(file);
    }
  }

  Future<Box?> _detectBox(Uint8List jpeg) async {
    final file = _tempFile();
    try {
      await file.writeAsBytes(jpeg, flush: true);
      final faces = await _boxDetector.processImage(
        InputImage.fromFilePath(file.path),
      );
      if (faces.isEmpty) return null;
      // Wajah terbesar = subjek utama.
      final b = faces
          .map((f) => f.boundingBox)
          .reduce((a, b) => a.width * a.height >= b.width * b.height ? a : b);
      return Box(b.left, b.top, b.width, b.height);
    } finally {
      await _delete(file);
    }
  }

  /// Potong dan perbesar di isolate supaya UI tidak tersendat.
  Future<Cropped?> _cropAndScale(Uint8List jpeg, Box box) {
    return Isolate.run(() {
      final decoded = img.decodeImage(jpeg);
      if (decoded == null) return null;
      final image = img.bakeOrientation(decoded);
      final w = image.width.toDouble();
      final h = image.height.toDouble();
      if (w < 2 || h < 2) return null;

      final mx = box.width * _boxMargin;
      final my = box.height * _boxMargin;
      // Kanvas potret 3:4 yang memuat wajah plus margin, tanpa memotong wajah.
      var cw = box.width + 2 * mx;
      var ch = box.height + 2 * my;
      if (ch < cw * 4 / 3) ch = cw * 4 / 3;
      if (cw < ch * 3 / 4) cw = ch * 3 / 4;
      cw = cw.clamp(16.0, w);
      ch = ch.clamp(16.0, h);

      final cx = box.left + box.width / 2;
      final cy = box.top + box.height / 2;
      final x0 = (cx - cw / 2).clamp(0.0, w - cw);
      final y0 = (cy - ch / 2).clamp(0.0, h - ch);

      final crop = img.copyCrop(
        image,
        x: x0.round(),
        y: y0.round(),
        width: cw.round(),
        height: ch.round(),
      );
      final scaleX = _retryWidth / cw;
      final scaleY = _retryHeight / ch;
      final resized = img.copyResize(
        crop,
        width: _retryWidth,
        height: _retryHeight,
        interpolation: img.Interpolation.cubic,
      );
      resized.exif = img.ExifData();
      return Cropped(img.encodeJpg(resized, quality: 95), x0, y0, scaleX, scaleY);
    });
  }

  File _tempFile() => File(
        '${Directory.systemTemp.path}/afaskin_${DateTime.now().microsecondsSinceEpoch}.jpg',
      );

  Future<void> _delete(File f) async {
    try {
      await f.delete();
    } on FileSystemException {
      // Sudah terhapus.
    }
  }

  Future<void> close() async {
    await _meshDetector.close();
    await _boxDetector.close();
  }
}

class Box {
  const Box(this.left, this.top, this.width, this.height);
  final double left;
  final double top;
  final double width;
  final double height;
}

/// Hasil potong: JPEG baru plus transformasi balik ke koordinat asli.
class Cropped {
  const Cropped(
    this.bytes,
    this.offsetX,
    this.offsetY,
    this.scaleX,
    this.scaleY,
  );
  final Uint8List bytes;
  final double offsetX;
  final double offsetY;
  final double scaleX;
  final double scaleY;
}
