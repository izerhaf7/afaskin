import 'dart:io';
import 'dart:typed_data';

import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';

/// 468 titik wajah dari ML Kit Face Mesh (on-device, Android). Topologinya sama
/// dengan MediaPipe Face Mesh yang dipakai saat training (notebook 03).
class FaceMeshService {
  final FaceMeshDetector _detector = FaceMeshDetector(option: FaceMeshDetectorOptions.faceMesh);

  /// Titik dalam koordinat piksel [jpeg]. `points` null kalau tidak ada wajah.
  Future<({int faces, List<(double, double)>? points})> detect(Uint8List jpeg) async {
    // ML Kit membaca dari file; file sementara langsung dihapus (foto tidak disimpan).
    final file = File(
      '${Directory.systemTemp.path}/afaskin_${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    await file.writeAsBytes(jpeg, flush: true);
    try {
      final meshes = await _detector.processImage(InputImage.fromFilePath(file.path));
      if (meshes.isEmpty) return (faces: 0, points: null);
      final pts = [...meshes.first.points]..sort((a, b) => a.index.compareTo(b.index));
      if (pts.length < 468) return (faces: meshes.length, points: null);
      return (faces: meshes.length, points: [for (final p in pts) (p.x, p.y)]);
    } finally {
      try {
        await file.delete();
      } on FileSystemException {
        // Sudah terhapus.
      }
    }
  }

  Future<void> close() => _detector.close();
}
