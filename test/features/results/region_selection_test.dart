import 'dart:convert';
import 'dart:io';

import 'package:afaskin/core/theme/app_theme.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/features/analysis/face_map.dart';
import 'package:afaskin/features/analysis/lesion_areas.dart';
import 'package:afaskin/features/analysis/problem_closeups.dart';
import 'package:afaskin/features/analysis/result_page.dart';
import 'package:afaskin/features/recommendation/recommendation_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Peta wajah memetakan lesi, bukan kotak wilayah:
/// 1. kotak lesi diketuk -> area dan kondisinya tersorot;
/// 2. ketukan kedua pada kotak yang sama melepas sorotan;
/// 3. kotak area lebih kecil dari petak, karena petak adalah wilayah yang
///    dinilai model, bukan ukuran lesinya;
/// 4. deteksi berdekatan pada kondisi sama digabung menjadi satu area.
Map<String, dynamic> _mock(String p) =>
    jsonDecode(File('assets/mock/$p').readAsStringSync()) as Map<String, dynamic>;

final _result = AnalysisResult.fromJson(_mock('analyze_success.json'));
final List<Product> _items =
    RecommendationList.fromJson(_mock('recommendations.json')).items;

/// Area pada foto depan, sama seperti yang dipakai peta.
List<LesionArea> _depan() => [
  for (final a in buildLesionAreas(_result.conditions))
    if (a.viewIndex == 0) a,
];

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(420, 9000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        recommendationsProvider(
          analysisId: _result.analysisId,
        ).overrideWith((ref) async => _items),
      ],
      child: MaterialApp(theme: AppTheme.light, home: Scaffold(body: child)),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

String? _selectedAreaId(WidgetTester tester) =>
    tester.widget<FaceMap>(find.byType(FaceMap).first).selectedAreaId;

/// Posisi tengah area dalam koordinat layar peta (mode skema: koordinat foto
/// dipetakan lurus ke kotak peta).
Offset _onMap(WidgetTester tester, LesionArea area) {
  final box = tester.getRect(find.byType(FaceMap).first);
  return box.topLeft +
      Offset(
        area.bounds.center.dx * box.width,
        area.bounds.center.dy * box.height,
      );
}

void main() {
  group('kelompokkanLesi', () {
    test('deteksi berdekatan menjadi satu area', () {
      final spots = [
        ConditionSpot(
          x: 0.50,
          y: 0.50,
          size: 0.15,
          label: SkinConditionLabel.acne,
          region: FaceRegion.leftCheek,
        ),
        ConditionSpot(
          x: 0.53,
          y: 0.52,
          size: 0.15,
          label: SkinConditionLabel.acne,
          region: FaceRegion.leftCheek,
        ),
      ];
      expect(kelompokkanLesi(spots, jarak: 0.09).length, 1);
    });
  });

  group('kotakArea', () {
    test('lebih kecil dari sisi petak, karena petak bukan ukuran lesi', () {
      final s = ConditionSpot(
        x: 0.5,
        y: 0.5,
        size: 0.15,
        label: SkinConditionLabel.acne,
        region: FaceRegion.leftCheek,
      );
      final r = kotakArea([s]);
      expect(r.width, lessThan(0.15));
      expect(r.width, greaterThan(0.04));
      // Tetap memuat titik tengah lesi.
      expect(r.contains(const Offset(0.5, 0.5)), isTrue);
    });

    test('dua lesi berjauhan menghasilkan kotak yang memuat keduanya', () {
      final a = ConditionSpot(
        x: 0.3,
        y: 0.4,
        size: 0.12,
        label: SkinConditionLabel.acne,
        region: FaceRegion.leftCheek,
      );
      final b = ConditionSpot(
        x: 0.6,
        y: 0.5,
        size: 0.12,
        label: SkinConditionLabel.acne,
        region: FaceRegion.rightCheek,
      );
      final r = kotakArea([a, b]);
      expect(r.contains(const Offset(0.3, 0.4)), isTrue);
      expect(r.contains(const Offset(0.6, 0.5)), isTrue);
    });
  });

  group('hitTestArea', () {
    test('titik di dalam kotak memilih area itu', () {
      final areas = _depan();
      if (areas.isEmpty) return;
      final first = areas.first;
      expect(hitTestArea(areas, first.bounds.center)?.id, first.id);
    });

    test('ketukan jauh dari semua kotak tidak memilih apa pun', () {
      final areas = _depan();
      expect(hitTestArea(areas, const Offset(-0.5, -0.5)), isNull);
    });
  });

  testWidgets('mengetuk kotak lesi menyorot area itu dan kondisinya', (
    tester,
  ) async {
    await _pump(tester, ResultView(result: _result));
    final areas = _depan();
    if (areas.isEmpty) return;
    expect(_selectedAreaId(tester), isNull);

    final target = areas.last;
    await tester.tapAt(_onMap(tester, target));
    await tester.pump(const Duration(milliseconds: 400));

    expect(_selectedAreaId(tester), target.id);
    expect(
      tester.widget<ProblemCloseups>(find.byType(ProblemCloseups)).selectedAreaId,
      target.id,
      reason: 'sorotan area harus menunjuk kartu area yang diketuk',
    );
  });

  testWidgets('ketukan kedua pada kotak yang sama melepas sorotan', (
    tester,
  ) async {
    await _pump(tester, ResultView(result: _result));
    final areas = _depan();
    if (areas.isEmpty) return;
    final target = areas.first;
    final at = _onMap(tester, target);

    await tester.tapAt(at);
    await tester.pump(const Duration(milliseconds: 400));
    expect(_selectedAreaId(tester), target.id);

    await tester.tapAt(at);
    await tester.pump(const Duration(milliseconds: 300));
    expect(_selectedAreaId(tester), isNull);
  });
}
