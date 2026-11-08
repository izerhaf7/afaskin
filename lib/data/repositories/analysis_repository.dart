import 'dart:typed_data';

import 'package:afaskin/data/models/models.dart';

/// Single entry point to the analysis backend.
///
/// Implementations: `AnalysisRepositoryMock` (bundled JSON),
/// `AnalysisRepositoryApi` (FastAPI over HTTP), and later an on-device
/// TFLite version. Every method throws a `Failure` subtype on error.
/// Tahap nyata sebuah analisis, selaras dengan daftar langkah di layar.
enum AnalysisStage {
  /// Membaca dan memeriksa kualitas foto.
  quality,

  /// Mendeteksi wajah dan memotong area kulit.
  regions,

  /// Menjalankan model kondisi kulit pada tiap potongan.
  condition,

  /// Menyusun rekomendasi produk dari katalog.
  matching,
}

abstract interface class AnalysisRepository {
  Future<HealthStatus> health();

  Future<Questionnaire> getQuestionnaire();

  /// [imageJpeg] (front view) must already be resized and stripped of EXIF;
  /// so must the optional [sideImagesJpeg] (up to two, head turned to each
  /// side). Throws `QualityRejected` when the front photo fails the server's
  /// quality gate; a side photo that fails is simply ignored by the server.
  /// [onStage] dipanggil saat analisis benar-benar masuk ke tahap berikutnya,
  /// supaya layar progres mengikuti kerja nyata dan bukan timer.
  Future<AnalysisResult> analyze({
    required Uint8List imageJpeg,
    required AnalyzePayload payload,
    List<Uint8List> sideImagesJpeg = const [],
    void Function(AnalysisStage stage)? onStage,
  });

  Future<List<Product>> getRecommendations({
    required String analysisId,
    ProductCategory? category,
    int? maxPrice,
  });

  Future<Product> getProduct(String id);
}
