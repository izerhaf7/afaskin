import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:afaskin/core/router/app_router.dart';
import 'package:afaskin/core/session/session_controller.dart';
import 'package:afaskin/core/theme/app_colors.dart';
import 'package:afaskin/core/theme/app_theme.dart';
import 'package:afaskin/core/widgets/afa_card.dart';
import 'package:afaskin/data/local/local_stores.dart';
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
        'Komedo putih', // 0.55
        'Papula', // 0.42
        'Jerawat', // 0.30
      ];
      await tester.dragUntilVisible(
        find.text('Jerawat'),
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
    testWidgets('list tile carries the same information without a photo', (
      tester,
    ) async {
      final withWarning = _items.firstWhere((p) => p.hasWarnings);
      await _pumpPlain(
        tester,
        ProductListTile(product: withWarning, onTap: () {}),
      );
      expect(find.text('Ada konflik bahan'), findsOneWidget);
      expect(find.text(withWarning.name), findsOneWidget);
      expect(find.text('${withWarning.brand} · Serum'), findsOneWidget);
      expect(find.byType(MatchBadge), findsOneWidget);
      // Tanpa foto: tidak boleh ada kotak gambar placeholder.
      expect(find.byType(ProductImage), findsNothing);
    });

    test('hasImage only when the catalog carries a URL', () {
      final p = _items.first;
      expect(p.copyWith(imageUrl: null).hasImage, isFalse);
      expect(p.copyWith(imageUrl: '').hasImage, isFalse);
      expect(p.copyWith(imageUrl: 'https://x/y.jpg').hasImage, isTrue);
    });

    testWidgets('shows "Ada konflik bahan" only when warnings exist', (
      tester,
    ) async {
      final withWarning = _items.firstWhere((p) => p.hasWarnings);
      final clean = _items.firstWhere((p) => !p.hasWarnings);

      await _pumpPlain(
        tester,
        SizedBox(
          width: 180,
          child: ProductCard(product: withWarning, onTap: () {}),
        ),
      );
      expect(find.text('Ada konflik bahan'), findsOneWidget);
      expect(find.text('Retinal 0.1% Night Serum'), findsOneWidget);
      expect(find.text('Kalma · Serum'), findsOneWidget);
      expect(find.text('Rp249.000'), findsOneWidget);
      expect(find.text('84% cocok'), findsOneWidget);

      await _pumpPlain(
        tester,
        SizedBox(
          width: 180,
          child: ProductCard(product: clean, onTap: () {}),
        ),
      );
      expect(find.text('Ada konflik bahan'), findsNothing);
    });
  });

  test('splitTitled reads "Judul: isi"', () {
    expect(splitTitled('Retinal: Mempercepat pergantian sel.'), (
      'Retinal',
      'Mempercepat pergantian sel.',
    ));
    expect(splitTitled('Tanpa judul'), (null, 'Tanpa judul'));
  });

  testWidgets('product detail: conflict banner, why list, ingredients', (
    tester,
  ) async {
    final p = Product.fromJson(_mock('product_detail.json'));
    await _pumpPlain(
      tester,
      ProviderScope(
        overrides: [
          flagStoreProvider.overrideWithValue(MemoryFlagStore()),
          userStoreProvider.overrideWithValue(MemoryUserStore()),
        ],
        child: ProductDetailView(product: p),
      ),
    );

    expect(
      find.text('Jangan dipakai bersamaan dengan produk ber-AHA/BHA'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Termasuk Clarifying Gel Cleanser'),
      findsOneWidget,
    );

    await tester.dragUntilVisible(
      find.byKey(const ValueKey('ingredient_retinal')),
      find.byType(Scrollable).first,
      const Offset(0, -200),
    );
    expect(find.text('Kenapa direkomendasikan'), findsOneWidget);
    // "Judul: isi" reasons render the title separately.
    expect(find.text('Retinal'), findsOneWidget);
    Color? colorOf(String ingredient) => tester
        .widget<Text>(
          find.descendant(
            of: find.byKey(ValueKey('ingredient_$ingredient')),
            matching: find.byType(Text),
          ),
        )
        .style
        ?.color;
    expect(colorOf('retinal'), AppColors.positive);
    expect(colorOf('aqua'), AppColors.ink);
  });

  testWidgets('favorite toggle and "Lihat di toko" opens the store link', (
    tester,
  ) async {
    final user = MemoryUserStore();
    final opened = <Uri>[];
    final p = Product.fromJson(_mock('product_detail.json'));
    await _pumpPlain(
      tester,
      ProviderScope(
        overrides: [
          flagStoreProvider.overrideWithValue(MemoryFlagStore()),
          userStoreProvider.overrideWithValue(user),
          storeLauncherProvider.overrideWithValue((uri) async {
            opened.add(uri);
            return true;
          }),
        ],
        child: ProductDetailView(product: p),
      ),
    );
    await tester.tap(find.byTooltip('Disimpan ke favorit'));
    await tester.pump();
    expect(user.favorites, {'prd_004'});
    await tester.tap(find.text('Lihat di toko'));
    await tester.pump();
    expect(opened.single.toString(), 'https://example.com/toko/prd_004');
  });

  testWidgets('recommendations: budget filter, categories, complete profile', (
    tester,
  ) async {
    final stores = setupDoneStores();
    // Fresh user from setup: no gender/budget yet.
    stores.user.profile = const UserProfile(age: 21);
    await pumpApp(
      tester,
      flags: stores.flags,
      user: stores.user,
      size: const Size(400, 2000), // whole grid fits on screen
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    final ctx = tester.element(find.text('Bagaimana kulitmu hari ini?'));
    ProviderScope.containerOf(ctx)
        .read(latestAnalysisProvider.notifier)
        .set(_result);
    unawaited(GoRouter.of(ctx).push(AppRoutes.recommendations('x')));
    await waitFor(tester, find.text('8 produk'));

    // No budget yet: all prices, "Lengkapi profilmu" card shown.
    expect(find.text('Semua harga'), findsOneWidget);
    expect(find.text('Lengkapi profilmu, yuk'), findsOneWidget);

    // Category filter.
    await tapVisible(tester, find.text('Sunscreen').first);
    await waitFor(tester, find.text('2 produk'));
    expect(find.text('Aqua Sun Fluid SPF 50'), findsOneWidget);
    await tapVisible(tester, find.text('Semua').first);
    await waitFor(tester, find.text('8 produk'));

    // Complete profile: gender, budget 150k -> filter turns on.
    await tapVisible(tester, find.text('Lengkapi · 2 pertanyaan'));
    expect(find.textContaining('Hasilnya sudah keluar!'), findsOneWidget);
    await tapVisible(tester, find.text('Tidak ingin menyebut'));
    await tapVisible(tester, find.text('Lanjut'));
    expect(
      find.text('Terakhir nih! Budget per produk kira-kira berapa?'),
      findsOneWidget,
    );
    await tapVisible(tester, find.text('Rp150.000'));
    await tapVisible(tester, find.text('Simpan'));
    await waitFor(tester, find.text('Maks Rp150.000'));
    expect(find.text('Lengkapi profilmu, yuk'), findsNothing);
    expect(find.text('Aqua Sun Fluid SPF 50'), findsNothing); // 319k
    expect(stores.user.profile!.gender, Gender.unspecified);

    // Budget sheet: tiny budget -> empty state; then "Semua harga".
    await tapVisible(tester, find.byKey(const Key('budget_chip')));
    await tapVisible(tester, find.text('Maks Rp50.000'));
    await waitFor(tester, find.text('Belum ada yang pas di budget ini'));
    await tapVisible(tester, find.byKey(const Key('budget_chip')));
    await tapVisible(tester, find.text('Semua harga').last);
    await waitFor(tester, find.text('8 produk'));

    // Detail.
    await tapVisible(tester, find.text('Retinal 0.1% Night Serum'));
    await waitFor(tester, find.text('Kenapa direkomendasikan'));
    expect(tester.takeException(), isNull);
  });
}
