import 'dart:convert';
import 'dart:io';

import 'package:afaskin/core/theme/app_theme.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/features/analysis/result_page.dart';
import 'package:afaskin/features/recommendation/recommendation_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Layar hasil menjawab tiga hal berurutan: kondisi apa, kandungan apa yang
/// membantu, lalu produk apa. Viewport dibuat tinggi supaya semua bagian ikut
/// dibangun tanpa menggulir (menggulir di tes rentan menggantung).
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
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  testWidgets('hasil menampilkan sorotan area, kandungan, lalu produk', (
    tester,
  ) async {
    await _pump(tester, ResultView(result: _result));

    expect(find.text('Peta wajah'), findsOneWidget);
    expect(find.text('Sorotan area'), findsOneWidget);
    expect(find.text('Kandungan yang dibutuhkan'), findsOneWidget);
    expect(find.text('Salicylic Acid'), findsWidgets);
    expect(
      find.text('BHA larut minyak, membersihkan sumbatan di dalam pori.'),
      findsWidgets,
    );
    expect(find.text('Rekomendasi produk'), findsOneWidget);
    expect(find.text('Lihat semua produk'), findsOneWidget);

    // Urutan di layar: kandungan di atas rekomendasi.
    final yIngredients = tester
        .getTopLeft(find.text('Kandungan yang dibutuhkan'))
        .dy;
    final yProducts = tester.getTopLeft(find.text('Rekomendasi produk')).dy;
    expect(yIngredients, lessThan(yProducts));
  });

  testWidgets('tanpa foto, sorotan area menjelaskan kenapa kosong', (
    tester,
  ) async {
    await _pump(tester, ResultView(result: _result));

    expect(find.text('Sorotan area'), findsOneWidget);
    expect(
      find.text('Sorotan foto hanya tersedia untuk analisis terbaru.'),
      findsOneWidget,
    );
  });

  testWidgets('kandungan mengikuti kondisi pada hasil', (tester) async {
    await _pump(tester, ResultView(result: _result));

    // Kondisi pada fixture: komedo hitam, papula, komedo putih, jerawat.
    expect(find.text('Retinol'), findsWidgets);
    expect(find.text('Tea Tree'), findsWidgets);
    expect(find.text('Sebaiknya dihindari'), findsWidgets);
  });
}
