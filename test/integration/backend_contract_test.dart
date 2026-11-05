/// Opt-in end-to-end check of the HTTP repository against a running backend
/// (the real FastAPI server, or tools/mock_server). Skipped unless
/// AFASKIN_API is set:
///
///   AFASKIN_API=http://127.0.0.1:8000 flutter test test/integration
library;

import 'dart:io';

import 'package:afaskin/core/network/dio_client.dart';
import 'package:afaskin/core/network/failures.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/data/repositories/analysis_repository_api.dart';
import 'package:afaskin/features/capture/photo_processing.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

class _DiskBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(await File(key).readAsBytes());
}

final String? _api = Platform.environment['AFASKIN_API'];

void main() {
  final skip = _api == null ? 'Set AFASKIN_API to run' : null;
  late AnalysisRepositoryApi repo;

  setUpAll(() {
    if (_api != null) {
      repo = AnalysisRepositoryApi(buildDio(baseUrl: _api!), _DiskBundle());
    }
  });

  test('health', () async {
    final h = await repo.health();
    expect(h.isOk, isTrue);
  }, skip: skip);

  test('questionnaire', () async {
    final q = await repo.getQuestionnaire();
    expect(q.questions, isNotEmpty);
  }, skip: skip);

  test('analyze -> recommendations -> product detail', () async {
    // A real JPEG through the same pipeline the app uses before upload.
    final photo = img.Image(width: 1600, height: 1200);
    img.fill(photo, color: img.ColorRgb8(196, 160, 140));
    final jpeg = preparePhotoForUpload(img.encodeJpg(photo));

    final q = await repo.getQuestionnaire();
    AnalysisResult result;
    try {
      result = await repo.analyze(
        imageJpeg: jpeg,
        payload: AnalyzePayload(
          profile: const UserProfile(
            age: 21,
            gender: Gender.female,
            budgetMax: 150000,
          ),
          questionnaire: {for (final x in q.questions) x.id: 3},
        ),
      );
    } on QualityRejected catch (e) {
      // A flat test image may be rejected by a real quality gate; that is a
      // valid contract response too.
      expect(e.reasons, isNotEmpty);
      return;
    }
    expect(result.analysisId, isNotEmpty);
    expect(result.rois, isNotEmpty);

    final items = await repo.getRecommendations(
      analysisId: result.analysisId,
      maxPrice: 150000,
    );
    expect(items.every((p) => p.price <= 150000), isTrue);
    if (items.isNotEmpty) {
      final p = await repo.getProduct(items.first.id);
      expect(p.ingredients, isNotNull);
    }
  }, skip: skip);
}
