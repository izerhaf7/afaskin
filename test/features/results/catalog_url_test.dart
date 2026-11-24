import 'dart:convert';
import 'dart:io';

import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/ml/fusion.dart';
import 'package:afaskin/ml/recommender.dart';
import 'package:flutter_test/flutter_test.dart';

/// Uji rantai penuh dari katalog asli sampai tombol toko: katalog membawa
/// `url`, `Recommender.item(detail: true)` meneruskannya sebagai `source_url`,
/// lalu `Product.fromJson` membacanya. Sebelumnya URL-nya dikarang sebagai
/// pencarian Sephora, sehingga brand lokal tidak pernah ketemu.
void main() {
  final catalog =
      jsonDecode(File('assets/ml/catalog.json').readAsStringSync()) as List;
  final cfg =
      (jsonDecode(File('assets/ml/ml_config.json').readAsStringSync())
          as Map<String, dynamic>)['recommender'] as Map<String, dynamic>;

  test('setiap produk di katalog membawa tautan Sociolla', () {
    expect(catalog.length, 824);
    var ada = 0;
    for (final p in catalog) {
      final m = p as Map<String, dynamic>;
      final u = m['url'] as String?;
      if (u != null && u.isNotEmpty) {
        ada++;
        expect(u, startsWith('https://www.sociolla.com/'), reason: '${m['name']}');
      }
    }
    expect(ada, catalog.length, reason: 'semua produk harus punya tautan');
  });

  test('item(detail: true) menyalurkan url asli, bukan pencarian toko lain', () {
    final rec = Recommender(
      products: [
        for (final p in catalog) CatalogProduct.fromJson(p as Map<String, dynamic>),
      ],
      cfg: cfg,
    );
    final first = rec.products.first;
    const profile = SkinProfile(
      pSkin: {'normal': 1},
      pCond: {'Clear': 1},
      sensitive: false,
    );

    final detail = rec.item(first, 0.5, profile, detail: true);
    expect(detail['source_url'], isNotNull);
    expect(detail['source_url'], first.url);
    expect(detail['source_url'], isNot(contains('sephora')));

    // Rantai baca: Product membacanya sebagai sourceUrl.
    final product = Product.fromJson({
      'id': first.id,
      'name': first.name,
      'brand': first.brand,
      'category': first.category,
      'price': first.price,
      'match_score': 0.5,
      ...detail,
    });
    expect(product.sourceUrl, first.url);
  });
}
