import 'dart:convert';
import 'dart:io';

import 'package:afaskin/core/theme/app_theme.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/features/analysis/face_map.dart';
import 'package:afaskin/features/analysis/problem_closeups.dart';
import 'package:afaskin/features/analysis/result_page.dart';
import 'package:afaskin/features/recommendation/recommendation_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Tiga perilaku pemilihan area yang dikeluhkan dan diperbaiki:
/// 1. mengetuk kartu close-up mana pun menyorot KARTU ITU (dulu selalu yang
///    paling kiri, karena area yang diketuk kalah dari "area pertama kondisi");
/// 2. mengetuk kotak di peta wajah menyorot kartu close-up-nya (dua arah);
/// 3. hanya satu area yang disorot pada satu waktu.
Map<String, dynamic> _mock(String p) =>
    jsonDecode(File('assets/mock/$p').readAsStringSync())
        as Map<String, dynamic>;

final _result = AnalysisResult.fromJson(_mock('analyze_success.json'));
final List<Product> _items = RecommendationList.fromJson(
  _mock('recommendations.json'),
).items;

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

Set<FaceRegion> _emphasized(WidgetTester tester) =>
    tester.widget<FaceMap>(find.byType(FaceMap).first).emphasized;

void main() {
  group('hitTestRegion', () {
    final rois = _result.rois;

    test('titik di dalam kotak mengembalikan area itu', () {
      for (final r in rois) {
        expect(hitTestRegion(rois, {r.name}, r.rect.center), r.name);
      }
    });

    test('hanya area yang disorot yang bisa dipilih', () {
      final cheek = rois.firstWhere((r) => r.name == FaceRegion.leftCheek);
      expect(hitTestRegion(rois, {FaceRegion.forehead}, cheek.rect.center),
          isNot(FaceRegion.leftCheek));
    });

    test('ketukan jauh dari semua kotak tidak memilih apa pun', () {
      expect(hitTestRegion(rois, {for (final r in rois) r.name},
          const Offset(0.01, 0.99)), isNull);
    });
  });

  testWidgets('mengetuk kotak TERAKHIR di peta menyorot kotak itu saja', (
    tester,
  ) async {
    // Tanpa foto, peta memakai gambar skema: kotak ROI dipetakan langsung ke
    // koordinat layar, jadi ketukan bisa diarahkan tepat ke satu area.
    await _pump(tester, ResultView(result: _result));
    expect(_emphasized(tester), isEmpty);

    final roi = _result.rois.last;
    final box = tester.getRect(find.byType(FaceMap));
    await tester.tapAt(
      box.topLeft +
          Offset(
            roi.rect.center.dx * box.width,
            roi.rect.center.dy * box.height,
          ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    // Dulu area yang diketuk kalah dari "area pertama kondisi terpilih",
    // sehingga yang menyala selalu kotak paling kiri.
    expect(_emphasized(tester), {roi.name});
    expect(
      tester.widget<ProblemCloseups>(find.byType(ProblemCloseups)).selected,
      roi.name,
      reason: 'peta harus menyorot kartu close-up-nya juga',
    );
  });

  testWidgets('ketukan kedua pada area yang sama melepas sorotan', (
    tester,
  ) async {
    await _pump(tester, ResultView(result: _result));
    final roi = _result.rois.last;
    final box = tester.getRect(find.byType(FaceMap));
    final at =
        box.topLeft +
        Offset(
          roi.rect.center.dx * box.width,
          roi.rect.center.dy * box.height,
        );

    await tester.tapAt(at);
    await tester.pump(const Duration(milliseconds: 300));
    expect(_emphasized(tester), {roi.name});

    await tester.tapAt(at);
    await tester.pump(const Duration(milliseconds: 300));
    expect(_emphasized(tester), isEmpty);
  });
}
