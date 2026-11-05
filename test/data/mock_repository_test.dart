import 'package:afaskin/core/network/failures.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/data/repositories/analysis_repository_mock.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  AnalysisRepositoryMock repo([MockScenario s = MockScenario.success]) =>
      AnalysisRepositoryMock(rootBundle, scenario: s, latency: Duration.zero);

  const payload = AnalyzePayload(
    profile: UserProfile(age: 21, gender: Gender.female, budgetMax: 150000),
    questionnaire: {'q1': 4},
  );

  test('analyze success', () async {
    final r = await repo().analyze(imageJpeg: Uint8List(0), payload: payload);
    expect(r.analysisId, isNotEmpty);
  });

  test('analyze quality_fail scenario throws QualityRejected', () async {
    await expectLater(
      repo(MockScenario.qualityFail)
          .analyze(imageJpeg: Uint8List(0), payload: payload),
      throwsA(isA<QualityRejected>()),
    );
  });

  test('recommendations filter by category and max price', () async {
    final all = await repo().getRecommendations(analysisId: 'x');
    final serums = await repo().getRecommendations(
      analysisId: 'x',
      category: ProductCategory.serum,
    );
    final cheap = await repo().getRecommendations(
      analysisId: 'x',
      maxPrice: 90000,
    );
    expect(serums, isNotEmpty);
    expect(serums.length, lessThan(all.length));
    expect(serums.every((p) => p.category == ProductCategory.serum), isTrue);
    expect(cheap.every((p) => p.price <= 90000), isTrue);
  });

  test('getProduct returns detail; unknown id -> ServerFailure', () async {
    final p = await repo().getProduct('prd_003');
    expect(p.ingredients, isNotEmpty);
    await expectLater(repo().getProduct('nope'), throwsA(isA<ServerFailure>()));
  });

  test('MockScenario.parse', () {
    expect(MockScenario.parse('quality_fail'), MockScenario.qualityFail);
    expect(MockScenario.parse('anything'), MockScenario.success);
  });
}
