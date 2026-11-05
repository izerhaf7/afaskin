import 'dart:convert';
import 'dart:io';

import 'package:afaskin/data/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _mock(String path) =>
    jsonDecode(File('assets/mock/$path').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  group('Mock JSON parses into models', () {
    test('health.json', () {
      final h = HealthStatus.fromJson(_mock('health.json'));
      expect(h.isOk, isTrue);
      expect(h.modelVersion, isNotEmpty);
    });

    test('questionnaire.json has q1..q7 with a 1-5 scale', () {
      final q = Questionnaire.fromJson(_mock('questionnaire.json'));
      expect(q.questions.map((e) => e.id), [
        for (var i = 1; i <= 7; i++) 'q$i',
      ]);
      for (final question in q.questions) {
        expect(question.scale.values, [1, 2, 3, 4, 5]);
        expect(question.scale.minLabel, isNotEmpty);
      }
    });

    test('analyze_success.json', () {
      final r = AnalysisResult.fromJson(_mock('analyze_success.json'));
      expect(r.skinType.label, SkinType.oily);
      expect(r.skinType.confidence, closeTo(0.78, 1e-9));
      expect(r.quality.passed, isTrue);
      expect(r.fusion.alpha, 0.6);
      expect(r.rois, hasLength(5));
      expect(r.rois.first.name, FaceRegion.forehead);
      expect(r.rois.first.rect.width, closeTo(0.40, 1e-9));
      expect(
        r.conditions.expand((c) => c.regions),
        isNot(contains(FaceRegion.unknown)),
      );
    });

    test('conditionsByProbability sorts highest first', () {
      final r = AnalysisResult.fromJson(_mock('analyze_success.json'));
      final probs = r.conditionsByProbability
          .map((c) => c.probability)
          .toList();
      expect(
        probs,
        orderedEquals(<double>[...probs]..sort((a, b) => b.compareTo(a))),
      );
      expect(r.topCondition?.label, SkinConditionLabel.blackhead);
    });

    test('analyze_quality_fail.json', () {
      final body = QualityRejectionBody.fromJson(
        _mock('analyze_quality_fail.json'),
      );
      expect(body.error, QualityRejectionBody.code);
      expect(body.reasons, ['too_dark', 'blurry']);
    });

    test('recommendations.json covers every category and has warnings', () {
      final list = RecommendationList.fromJson(_mock('recommendations.json'));
      expect(
        list.items.map((p) => p.category).toSet(),
        containsAll(<ProductCategory>[
          ProductCategory.cleanser,
          ProductCategory.toner,
          ProductCategory.serum,
          ProductCategory.moisturizer,
          ProductCategory.sunscreen,
        ]),
      );
      expect(list.items.any((p) => p.hasWarnings), isTrue);
      expect(list.items.every((p) => p.ingredients == null), isTrue);
    });

    test('product_detail.json and every products/<id>.json', () {
      final detail = Product.fromJson(_mock('product_detail.json'));
      expect(detail.hasWarnings, isTrue);
      expect(detail.ingredients, isNotEmpty);
      expect(detail.sourceUrl, isNotNull);

      final list = RecommendationList.fromJson(_mock('recommendations.json'));
      for (final item in list.items) {
        final p = Product.fromJson(_mock('products/${item.id}.json'));
        expect(p.id, item.id);
        expect(p.ingredients, isNotEmpty);
        // Every matched ingredient should be highlightable in the INCI list.
        for (final m in p.matchedIngredients) {
          expect(
            p.ingredients!.any(p.isMatchedIngredient),
            isTrue,
            reason: '$m in ${p.id}',
          );
        }
      }
    });

    test('unknown enum values do not crash parsing', () {
      final c = SkinCondition.fromJson(const {
        'label': 'rosacea',
        'probability': 0.1,
        'regions': ['ear'],
      });
      expect(c.label, SkinConditionLabel.unknown);
      expect(c.regions, [FaceRegion.unknown]);
    });

    test('AnalyzePayload serializes to the contract shape', () {
      const payload = AnalyzePayload(
        profile: UserProfile(age: 21, gender: Gender.female, budgetMax: 150000),
        questionnaire: {'q1': 4, 'q2': 2},
      );
      expect(jsonDecode(jsonEncode(payload.toJson())), {
        'profile': {'age': 21, 'gender': 'female', 'budget_max': 150000},
        'questionnaire': {'q1': 4, 'q2': 2},
      });
    });
  });
}
