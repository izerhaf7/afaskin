import 'dart:convert';

import 'package:afaskin/core/network/failures.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/data/repositories/analysis_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum MockScenario {
  success,
  qualityFail;

  static MockScenario parse(String value) =>
      value == 'quality_fail' ? qualityFail : success;
}

/// Reads responses from `assets/mock/`. Lets the whole UI run without a
/// server. Filtering for `/recommendations` is done here like the server would.
class AnalysisRepositoryMock implements AnalysisRepository {
  AnalysisRepositoryMock(
    this._bundle, {
    this.scenario = MockScenario.success,
    this.latency = const Duration(milliseconds: 600),
  });

  final AssetBundle _bundle;
  final MockScenario scenario;

  /// Fake network delay. Use [Duration.zero] in tests.
  final Duration latency;

  static const _dir = 'assets/mock';

  Future<Map<String, dynamic>> _load(String path) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    try {
      final raw = await _bundle.loadString('$_dir/$path');
      return jsonDecode(raw) as Map<String, dynamic>;
      // A missing asset is reported as FlutterError; treat it like a 404.
      // ignore: avoid_catching_errors
    } on FlutterError {
      throw const ServerFailure(statusCode: 404);
    }
  }

  @override
  Future<HealthStatus> health() async =>
      HealthStatus.fromJson(await _load('health.json'));

  @override
  Future<Questionnaire> getQuestionnaire() async =>
      Questionnaire.fromJson(await _load('questionnaire.json'));

  @override
  Future<AnalysisResult> analyze({
    required Uint8List imageJpeg,
    required AnalyzePayload payload,
    List<Uint8List> sideImagesJpeg = const [],
    void Function(AnalysisStage stage)? onStage,
  }) async {
    if (scenario == MockScenario.qualityFail) {
      final body = QualityRejectionBody.fromJson(
        await _load('analyze_quality_fail.json'),
      );
      throw QualityRejected(reasons: body.reasons, serverMessage: body.message);
    }
    return AnalysisResult.fromJson(await _load('analyze_success.json'));
  }

  @override
  Future<List<Product>> getRecommendations({
    required String analysisId,
    ProductCategory? category,
    int? maxPrice,
  }) async {
    final list = RecommendationList.fromJson(
      await _load('recommendations.json'),
    );
    return list.items
        .where((p) => category == null || p.category == category)
        .where((p) => maxPrice == null || p.price <= maxPrice)
        .toList();
  }

  @override
  Future<Product> getProduct(String id) async =>
      Product.fromJson(await _load('products/$id.json'));
}
