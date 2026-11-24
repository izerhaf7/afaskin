import 'package:afaskin/core/l10n/app_strings.dart';
import 'package:afaskin/core/session/session_controller.dart';
import 'package:afaskin/data/local/local_stores.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/features/recommendation/product_detail_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Tautan "Lihat di toko" harus membuka halaman produk yang sebenarnya, bukan
/// pencarian di toko lain. Sebelumnya aplikasi mengarang URL pencarian Sephora
/// dari nama produk, sehingga produk brand lokal tidak pernah ketemu.
Product _produk({String? url}) => Product(
  id: '116107',
  name: 'Noni Probiotics Calm Me Down',
  brand: 'Noni',
  category: ProductCategory.serum,
  price: 149000,
  matchScore: 0.8,
  sourceUrl: url,
);

Future<void> _pump(
  WidgetTester tester,
  Product product, {
  Future<bool> Function(Uri)? launcher,
}) async {
  tester.view.physicalSize = const Size(430, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        flagStoreProvider.overrideWithValue(MemoryFlagStore()),
        userStoreProvider.overrideWithValue(MemoryUserStore()),
        storeLauncherProvider.overrideWithValue(launcher ?? (uri) async => true),
      ],
      child: MaterialApp(home: ProductDetailView(product: product)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('tombol toko membuka URL produk aslinya', (tester) async {
    Uri? dibuka;
    await _pump(
      tester,
      _produk(url: 'https://www.sociolla.com/face-serum/87765-noni-probiotics'),
      launcher: (uri) async {
        dibuka = uri;
        return true;
      },
    );

    expect(find.text(AppStrings.openStore), findsOneWidget);
    await tester.tap(find.text(AppStrings.openStore));
    await tester.pumpAndSettle();

    expect(dibuka, isNotNull);
    expect(dibuka!.host, 'www.sociolla.com');
    expect(dibuka!.path, contains('noni-probiotics'));
  });

  testWidgets('tanpa URL, tombol toko tidak ditampilkan', (tester) async {
    await _pump(tester, _produk());
    expect(find.text(AppStrings.openStore), findsNothing);
  });

  testWidgets('URL yang bukan tautan http juga tidak memunculkan tombol', (
    tester,
  ) async {
    await _pump(tester, _produk(url: 'bukan url'));
    expect(find.text(AppStrings.openStore), findsNothing);
  });
}
