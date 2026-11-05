import 'dart:convert';

import 'package:afaskin/core/network/error_mapper.dart';
import 'package:afaskin/core/network/failures.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/data/repositories/analysis_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// HTTP implementation against the FastAPI backend (`/api/v1`).
///
/// Written against the contract; verified end-to-end in Phase 5.
class AnalysisRepositoryApi implements AnalysisRepository {
  AnalysisRepositoryApi(this._dio, this._bundle);

  final Dio _dio;

  /// For the bundled questionnaire fallback.
  final AssetBundle _bundle;

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on Failure {
      rethrow;
    } on Object catch (e) {
      if (e is DioException) throw mapToFailure(e);
      // Bad JSON shape, etc.
      throw const ServerFailure();
    }
  }

  Map<String, dynamic> _json(Response<dynamic> r) {
    final data = r.data;
    if (data is Map<String, dynamic>) return data;
    if (data is String) return jsonDecode(data) as Map<String, dynamic>;
    throw const ServerFailure();
  }

  @override
  Future<HealthStatus> health() => _guard(
    () async => HealthStatus.fromJson(_json(await _dio.get('/health'))),
  );

  @override
  Future<Questionnaire> getQuestionnaire() async {
    try {
      return await _guard(
        () async =>
            Questionnaire.fromJson(_json(await _dio.get('/questionnaire'))),
      );
    } on Failure catch (e) {
      // Questions are a draft and may change server-side, but the app must
      // still work offline: fall back to the bundled copy.
      debugPrint('Questionnaire fallback to local asset: $e');
      final raw = await _bundle.loadString('assets/mock/questionnaire.json');
      return Questionnaire.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }
  }

  @override
  Future<AnalysisResult> analyze({
    required Uint8List imageJpeg,
    required AnalyzePayload payload,
  }) => _guard(() async {
    final form = FormData.fromMap({
      'image': MultipartFile.fromBytes(
        imageJpeg,
        filename: 'face.jpg',
        contentType: DioMediaType('image', 'jpeg'),
      ),
      'payload': jsonEncode(payload.toJson()),
    });
    final r = await _dio.post<dynamic>('/analyze', data: form);
    return AnalysisResult.fromJson(_json(r));
  });

  @override
  Future<List<Product>> getRecommendations({
    required String analysisId,
    ProductCategory? category,
    int? maxPrice,
  }) => _guard(() async {
    final r = await _dio.get<dynamic>(
      '/recommendations',
      queryParameters: {
        'analysis_id': analysisId,
        if (category != null && category != ProductCategory.unknown)
          'category': category.name,
        'max_price': ?maxPrice,
      },
    );
    return RecommendationList.fromJson(_json(r)).items;
  });

  @override
  Future<Product> getProduct(String id) => _guard(
    () async => Product.fromJson(
      _json(await _dio.get<dynamic>('/products/${Uri.encodeComponent(id)}')),
    ),
  );
}
