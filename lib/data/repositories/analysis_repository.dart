import 'dart:typed_data';

import 'package:afaskin/data/models/models.dart';

/// Single entry point to the analysis backend.
///
/// Implementations: `AnalysisRepositoryMock` (bundled JSON),
/// `AnalysisRepositoryApi` (FastAPI over HTTP), and later an on-device
/// TFLite version. Every method throws a `Failure` subtype on error.
abstract interface class AnalysisRepository {
  Future<HealthStatus> health();

  Future<Questionnaire> getQuestionnaire();

  /// [imageJpeg] must already be resized and stripped of EXIF.
  /// Throws `QualityRejected` when the server's quality gate fails.
  Future<AnalysisResult> analyze({
    required Uint8List imageJpeg,
    required AnalyzePayload payload,
  });

  Future<List<Product>> getRecommendations({
    required String analysisId,
    ProductCategory? category,
    int? maxPrice,
  });

  Future<Product> getProduct(String id);
}
