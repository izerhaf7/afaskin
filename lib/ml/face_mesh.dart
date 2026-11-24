import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
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

  /// Panjang sisi terpanjang saat mencoba ulang pada foto utuh yang diperkecil.
  static const int _fullResize = 640;

  /// Urutan percobaan ulang setelah Face Mesh menolak foto asli.
  ///
  /// Satu percobaan tidak cukup: foto yang terpotong di pipi punya kotak wajah
  /// yang menyentuh tepi gambar, sehingga potongan 3:4 dengan margin lebar tetap
  /// memotong wajah dan Face Mesh menolaknya lagi. Urutan ini menurunkan margin
  /// bertahap, lalu mencoba foto utuh yang diperkecil sebagai upaya terakhir —
  /// jalur itu menyelamatkan wajah yang sudah besar di dalam frame.
  static const List<({double margin, bool portrait})> _attempts = [
    (margin: 0.55, portrait: true),
    (margin: 0.35, portrait: true),
    (margin: 0.20, portrait: true),
    (margin: 0.80, portrait: false),
  ];

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
        // Beberapa geometri potong dicoba berurutan; yang pertama menghasilkan
        // mesh dipakai. Wajah yang menyentuh tepi foto butuh margin lebih kecil,
        // wajah kecil di foto besar butuh potongan lebih lebar.
        final tried = <String>[];
        for (final a in _attempts) {
          final cropped = await _cropAndScale(jpeg, box, a.margin, a.portrait);
          if (cropped == null) continue;
          final pts = await _mesh(cropped.bytes);
          tried.add('${a.margin.toStringAsFixed(2)}:${pts != null}');
          if (pts == null) continue;
          trace['retry'] = a.margin;
          trace['tried'] = tried;
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
        trace['tried'] = tried;
      }

      // Upaya terakhir: perkecil foto utuh. Face Mesh kadang menolak foto
      // beresolusi tinggi yang wajahnya sudah bagus, dan penskalaan ulang
      // mengubahnya menjadi gambar yang diterima.
      final resized = await _resizeFull(jpeg);
      if (resized != null) {
        final pts = await _mesh(resized.bytes);
        trace['full_resize'] = pts != null;
        if (pts != null) {
          _trace(trace);
          return (
            faces: 1,
            points: [
              for (final (x, y) in pts)
                (resized.offsetX + x / resized.scaleX,
                 resized.offsetY + y / resized.scaleY),
            ],
          );
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
  ///
  /// [margin] relatif terhadap sisi kotak wajah. [portrait] memaksa kanvas 3:4
  /// tegak; kalau false, kanvas mengikuti bentuk kotak wajah apa adanya (lebih
  /// aman untuk wajah yang sudah lebar atau terpotong di sisi).
  Future<Cropped?> _cropAndScale(
    Uint8List jpeg,
    Box box,
    double margin,
    bool portrait,
  ) {
    return Isolate.run(() {
      final decoded = img.decodeImage(jpeg);
      if (decoded == null) return null;
      final image = img.bakeOrientation(decoded);
      final w = image.width.toDouble();
      final h = image.height.toDouble();
      if (w < 2 || h < 2) return null;

      final mx = box.width * margin;
      final my = box.height * margin;
      var cw = box.width + 2 * mx;
      var ch = box.height + 2 * my;
      if (portrait) {
        if (ch < cw * 4 / 3) ch = cw * 4 / 3;
        if (cw < ch * 3 / 4) cw = ch * 3 / 4;
      }
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
      final tw = portrait ? _retryWidth : _retryHeight;
      final th = portrait ? _retryHeight : _retryWidth;
      final scaleX = tw / cw;
      final scaleY = th / ch;
      final resized = img.copyResize(
        crop,
        width: tw,
        height: th,
        interpolation: img.Interpolation.cubic,
      );
      resized.exif = img.ExifData();
      return Cropped(img.encodeJpg(resized, quality: 95), x0, y0, scaleX, scaleY);
    });
  }

  /// Perkecil foto utuh ke sisi terpanjang [_fullResize], tanpa memotong.
  Future<Cropped?> _resizeFull(Uint8List jpeg) {
    return Isolate.run(() {
      final decoded = img.decodeImage(jpeg);
      if (decoded == null) return null;
      final image = img.bakeOrientation(decoded);
      final w = image.width, h = image.height;
      if (w < 2 || h < 2) return null;
      final longest = math.max(w, h);
      // Sudah cukup kecil: memperkecil lagi tidak menambah apa pun.
      if (longest <= _fullResize) return null;
      final k = _fullResize / longest;
      final tw = (w * k).round().clamp(16, _fullResize);
      final th = (h * k).round().clamp(16, _fullResize);
      final resized = img.copyResize(
        image,
        width: tw,
        height: th,
        interpolation: img.Interpolation.cubic,
      );
      resized.exif = img.ExifData();
      return Cropped(img.encodeJpg(resized, quality: 92), 0, 0, tw / w, th / h);
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
