import 'dart:async';

import 'dart:convert';
import 'dart:io';

import 'package:afaskin/core/router/app_router.dart';
import 'package:afaskin/core/theme/app_theme.dart';
import 'package:afaskin/core/widgets/afa_card.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/features/analysis/analysis_flow.dart';
import 'package:afaskin/features/analysis/result_page.dart';
import 'package:afaskin/features/recommendation/product_detail_page.dart';
import 'package:afaskin/features/recommendation/product_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers.dart';

Map<String, dynamic> _mock(String p) =>
    jsonDecode(File('assets/mock/$p').readAsStringSync())
        as Map<String, dynamic>;

final _result = AnalysisResult.fromJson(_mock('analyze_success.json'));
final List<Product> _items = RecommendationList.fromJson(
  _mock('recommendations.json'),
).items;

Future<void> _pumpPlain(
  WidgetTester tester,
  Widget child, {
  double scale = 1,
}) async {
  tester.view.physicalSize = const Size(360, 720);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      builder: (c, w) => MediaQuery(
        data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(scale)),
        child: w!,
      ),
      home: Scaffold(body: child),
    ),
  );
}

Future<void> _scrollAll(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
    await tester.pump();
  }
}

void main() {
  group('Result screen (mock data)', () {
    testWidgets('skin type, confidence and conditions sorted by probability', (
      tester,
    ) async {
      await _pumpPlain(tester, ResultView(result: _result));

      expect(find.text('Berminyak'), findsWidgets);
      expect(find.text('78% keyakinan'), findsOneWidget);

      // Mock JSON is deliberately out of order; UI must sort.
      final order = [
        'Komedo hitam', // 0.71
        'Jerawat', // 0.46
        'Komedo putih', // 0.33
        'Papula', // 0.18
      ];
      await tester.dragUntilVisible(
        find.text('Papula'),
        find.byType(Scrollable).first,
        const Offset(0, -200),
      );
      final ys = [
        for (final t in order) tester.getTopLeft(find.text(t).first).dy,
      ];
      expect(ys, orderedEquals([...ys]..sort()));
      expect(find.text('71%'), findsOneWidget);
      // API description is used when present.
      expect(
        find.text('Komedo terbuka akibat pori tersumbat sebum.'),
        findsOneWidget,
      );
    });

    testWidgets('tapping a condition selects it (face map emphasis)', (
      tester,
    ) async {
      await _pumpPlain(tester, ResultView(result: _result));
      await tester.dragUntilVisible(
        find.text('Komedo hitam'),
        find.byType(Scrollable).first,
        const Offset(0, -200),
      );
      final card = find.ancestor(
        of: find.text('Komedo hitam'),
        matching: find.byType(AfaCard),
      );
      await tester.ensureVisible(card.first);
      await tester.pumpAndSettle();
      await tester.tap(card.first);
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(card.first),
        isSemantics(isSelected: true, isButton: true),
      );
    });

    testWidgets('no overflow at 130% text scale', (tester) async {
      await _pumpPlain(tester, ResultView(result: _result), scale: 1.3);
      await _scrollAll(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dermatologist banner for cysts/purulent', (tester) async {
      final withCyst = _result.copyWith(
        conditions: [
          const SkinCondition(
            label: SkinConditionLabel.cysts,
            probability: 0.5,
            regions: [FaceRegion.chin],
          ),
        ],
      );
      await _pumpPlain(tester, ResultView(result: withCyst));
      expect(find.text('Pertimbangkan ke dokter kulit'), findsOneWidget);
      await _pumpPlain(tester, ResultView(result: _result));
      expect(find.text('Pertimbangkan ke dokter kulit'), findsNothing);
    });
  });

  group('Product card', () {
    testWidgets('shows a danger warning chip only when warnings exist', (
      tester,
    ) async {
      final withWarning = _items.firstWhere((p) => p.hasWarnings);
      final clean = _items.firstWhere((p) => !p.hasWarnings);

      await _pumpPlain(tester, ProductCard(product: withWarning, onTap: () {}));
      expect(find.text('Ada peringatan bahan'), findsOneWidget);
      expect(find.text(withWarning.name), findsOneWidget);
      expect(find.text('Rp139.000'), findsOneWidget);
      expect(find.text('74% cocok'), findsOneWidget);

      await _pumpPlain(tester, ProductCard(product: clean, onTap: () {}));
      expect(find.text('Ada peringatan bahan'), findsNothing);
    });
  });

  testWidgets('product detail: conflict banner and highlighted ingredients', (
    tester,
  ) async {
    final p = Product.fromJson(_mock('product_detail.json'));
    await _pumpPlain(tester, ProductDetailView(product: p));

    expect(find.text('Peringatan konflik bahan aktif'), findsOneWidget);
    expect(find.textContaining('retinol dan AHA'), findsOneWidget);
    expect(find.text('Kenapa direkomendasikan'), findsOneWidget);

    await tester.dragUntilVisible(
      find.byKey(const ValueKey('ingredient_retinol')),
      find.byType(Scrollable).first,
      const Offset(0, -200),
    );
    Color? colorOf(String ingredient) => tester
        .widget<Text>(
          find.descendant(
            of: find.byKey(ValueKey('ingredient_$ingredient')),
            matching: find.byType(Text),
          ),
        )
        .style
        ?.color;
    expect(colorOf('retinol'), isNot(colorOf('aqua')));
  });

  testWidgets('result -> recommendations (filters) -> product detail', (
    tester,
  ) async {
    final stores = setupDoneStores();
    await pumpApp(
      tester,
      flags: stores.flags,
      user: stores.user,
      size: const Size(400, 1600), // whole product list fits on screen
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    final ctx = tester.element(find.text('Siap cek kulitmu?'));
    ProviderScope.containerOf(ctx)
        .read(latestAnalysisProvider.notifier)
        .set(_result);
    unawaited(GoRouter.of(ctx).push(AppRoutes.result));
    await tester.pumpAndSettle();

    await tapVisible(tester, find.text('Lihat rekomendasi produk'));
    await waitFor(tester, find.byType(ProductCard));

    // Default budget = profile budget (150k): the 175k serum is hidden.
    expect(find.text('Brightening Vitamin C 15% Serum'), findsNothing);
    await tapVisible(tester, find.text('Semua harga'));
    await waitFor(tester, find.text('Brightening Vitamin C 15% Serum'));

    // Category filter.
    await tapVisible(tester, find.text('Serum').first);
    await waitFor(tester, find.text('Niacinamide 10% Oil Control Serum'));
    expect(find.text('Gentle Balance Low pH Cleanser'), findsNothing);

    // Empty state + reset.
    await tester.drag(find.byType(Scrollable).at(1), const Offset(-600, 0));
    await tapVisible(tester, find.text('Sampai Rp50.000'));
    await waitFor(tester, find.text('Tidak ada produk untuk filter ini.'));
    await tapVisible(tester, find.text('Atur ulang filter'));
    await waitFor(tester, find.text('Gentle Balance Low pH Cleanser'));

    // Detail.
    await tapVisible(tester, find.text('Night Renewal Retinol + AHA Serum'));
    await waitFor(tester, find.text('Peringatan konflik bahan aktif'));
    expect(tester.takeException(), isNull);
  });
}
