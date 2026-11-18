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

/// Peta wajah memetakan lesi, bukan kotak wilayah:
/// 1. gumpalan diketuk -> kondisi itu yang tersorot (bukan kotak wilayah);
/// 2. ketukan kedua pada gumpalan yang sama melepas sorotan;
/// 3. sorotan peta diikuti kartu sorotan kondisi itu.
Map<String, dynamic> _mock(String p) => jsonDecode(File('assets/mock/$p').readAsStringSync())
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

SkinConditionLabel? _emphasized(WidgetTester tester) =>
    tester.widget<FaceMap>(find.byType(FaceMap).first).emphasizedLabel;

/// Posisi gumpalan [spot] dalam koordinat layar peta (mode skema: koordinat
/// foto dipetakan lurus ke kotak peta).
Offset _onMap(WidgetTester tester, ConditionSpot spot) {
  final box = tester.getRect(find.byType(FaceMap).first);
  return box.topLeft + Offset(spot.x * box.width, spot.y * box.height);
}

void main() {
  group('hitTestSpot', () {
    final spots = [for (final c in _result.conditions) ...c.spots];
    final first = spots.first;

    test('titik di tengah gumpalan mengembalikan kondisi itu', () {
      expect(hitTestSpot(spots, Offset(first.x, first.y)), first.label);
    });

    test('gumpalan lain tidak menangkap ketukan ini', () {
      final other = spots.last;
      expect(hitTestSpot(spots, Offset(other.x, other.y)), other.label);
    });

    test('ketukan jauh dari semua gumpalan tidak memilih apa pun', () {
      expect(hitTestSpot(spots, const Offset(0.01, 0.99)), isNull);
    });
  });

  testWidgets('mengetuk gumpalan menyorot kondisi itu saja', (tester) async {
    await _pump(tester, ResultView(result: _result));
    expect(_emphasized(tester), isNull);

    // Kondisi terakhir di daftar punya gumpalan sendiri; ketukan harus memilih
    // kondisi itu, bukan kondisi pertama seperti perilaku kotak wilayah dulu.
    final target = _result.conditions.last;
    await tester.tapAt(_onMap(tester, target.spots.first));
    await tester.pump(const Duration(milliseconds: 400));

    expect(_emphasized(tester), target.label);
    expect(
      tester.widget<ProblemCloseups>(find.byType(ProblemCloseups)).selected,
      target.label,
      reason: 'peta harus menyorot sorotan kondisi yang diketuk',
    );
  });

  testWidgets('ketukan kedua pada gumpalan yang sama melepas sorotan', (
    tester,
  ) async {
    await _pump(tester, ResultView(result: _result));
    final target = _result.conditions.last;
    final at = _onMap(tester, target.spots.first);

    await tester.tapAt(at);
    await tester.pump(const Duration(milliseconds: 300));
    expect(_emphasized(tester), target.label);

    await tester.tapAt(at);
    await tester.pump(const Duration(milliseconds: 300));
    expect(_emphasized(tester), isNull);
  });

}
