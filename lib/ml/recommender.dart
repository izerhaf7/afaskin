import 'dart:math' as math;

import 'package:afaskin/ml/fusion.dart';
import 'package:afaskin/ml/ml_texts.dart';

/// Satu produk dari `assets/ml/catalog.json` (hasil notebook 06).
class CatalogProduct {
  CatalogProduct.fromJson(Map<String, dynamic> j)
    : id = j['id'] as String,
      name = j['name'] as String,
      brand = j['brand'] as String,
      category = j['category'] as String,
      price = j['price'] as int,
      rating = (j['rating'] as num?)?.toDouble(),
      reviews = j['reviews'] as int,
      tag = (j['tag'] as Map).map((k, v) => MapEntry(k as String, (v as num).toDouble())),
      quality = (j['quality'] as Map).map((k, v) => MapEntry(k as String, (v as num).toDouble())),
      actives = (j['actives'] as List).cast<String>().toSet(),
      matched = (j['matched'] as Map).map(
        (k, v) => MapEntry(k as String, (v as List).cast<String>()),
      ),
      ingredients = (j['ingredients'] as List).cast<String>();

  final String id, name, brand, category;
  final int price, reviews;
  final double? rating;

  /// Skor model relevansi kondisi (persentil 0-1) per tag manfaat.
  final Map<String, double> tag;

  /// Skor kecocokan per tipe kulit (persentil 0-1, dari ulasan/model).
  final Map<String, double> quality;
  final Set<String> actives;

  /// Bahan aktif -> nama bahan asli di produk yang cocok.
  final Map<String, List<String>> matched;
  final List<String> ingredients;
}

const _skin = ['dry', 'normal', 'oily'];
const _acneGroup = ['Acne', 'Papular', 'Purulent', 'Cysts', 'Blackhead', 'Whitehead'];
const appCategories = ['cleanser', 'toner', 'serum', 'moisturizer', 'sunscreen'];

/// Port `recommender.py`: skor hybrid (relevansi kondisi + kecocokan tipe kulit
/// + matriks bahan) dengan filter keamanan dan penjelasan.
class Recommender {
  Recommender({required this.products, required Map<String, dynamic> cfg})
    : weights = (cfg['weights'] as List).map((e) => (e as num).toDouble()).toList(),
      actives = (cfg['actives'] as List).cast<String>(),
      mapping = (cfg['mapping'] as List).cast<Map<String, dynamic>>(),
      classToTag = (cfg['class_to_tag'] as Map).map(
        (k, v) => MapEntry(
          k as String,
          (v as Map).map((t, w) => MapEntry(t as String, (w as num).toDouble())),
        ),
      ),
      byId = {for (final p in products) p.id: p};

  final List<CatalogProduct> products;
  final Map<String, CatalogProduct> byId;
  final List<double> weights;
  final List<String> actives;
  final List<Map<String, dynamic>> mapping;
  final Map<String, Map<String, double>> classToTag;

  // ------------------------------------------------------------ profil
  Set<String> avoidSet(SkinProfile p) {
    final targets = <String>[
      if (p.sensitive) 'Sensitive',
      if (_acneGroup.fold<double>(0, (a, c) => a + (p.pCond[c] ?? 0)) >= 0.3) 'Acne',
      if ((p.pCond['Milium'] ?? 0) >= 0.3) 'Milium',
      if ((p.pSkin['dry'] ?? 0) >= 0.5) 'Dry',
    ];
    return {
      for (final r in mapping)
        if (targets.contains(r['target']) && r['role'] == 'avoid') r['ingredient'] as String,
    };
  }

  Map<String, double> _needTargets(SkinProfile p) => {
    for (final e in p.pCond.entries)
      if (e.value >= 0.1 && e.key != 'Clear') e.key: e.value,
    for (final e in p.pSkin.entries) _capitalize(e.key): e.value,
    if (p.sensitive) 'Sensitive': 1.0,
  };

  /// Bobot kebutuhan per bahan aktif + target asal bobot itu (untuk alasan).
  ({Map<String, double> need, Map<String, List<(String, double)>> src}) needVector(SkinProfile p) {
    final need = {for (final a in actives) a: 0.0};
    final src = {for (final a in actives) a: <(String, double)>[]};
    for (final t in _needTargets(p).entries) {
      for (final r in mapping) {
        final ing = r['ingredient'] as String;
        if (r['target'] == t.key && need.containsKey(ing) && r['role'] == 'recommended') {
          need[ing] = need[ing]! + t.value * (r['weight'] as num).toDouble();
          src[ing]!.add((t.key, t.value));
        }
      }
    }
    return (need: need, src: src);
  }

  // ------------------------------------------------------------ skor
  /// Skor produk yang lolos filter, urut menurun.
  List<(CatalogProduct, double)> score(SkinProfile p, {String? category, int? maxPrice}) {
    final pool = [for (final x in products) if (category == null || x.category == category) x];
    final tagW = <String, double>{};
    for (final e in p.pCond.entries) {
      for (final t in (classToTag[e.key] ?? const <String, double>{}).entries) {
        tagW[t.key] = (tagW[t.key] ?? 0) + e.value * t.value;
      }
    }
    if (p.sensitive) tagW['redness'] = (tagW['redness'] ?? 0) + 0.5;
    final tagSum = tagW.values.fold<double>(0, (a, b) => a + b);
    final need = needVector(p).need;
    final needNorm = math.sqrt(need.values.fold<double>(0, (a, b) => a + b * b));
    final know = [
      for (final x in pool)
        () {
          final dot = x.actives.fold<double>(0, (a, act) => a + (need[act] ?? 0));
          return dot / (math.sqrt(x.actives.length.toDouble()) * needNorm + 1e-9);
        }(),
    ];
    final knowPct = _rankPct(know);
    final bad = avoidSet(p);
    final out = <(CatalogProduct, double)>[];
    for (var i = 0; i < pool.length; i++) {
      final x = pool[i];
      if (x.actives.any(bad.contains)) continue;
      if (maxPrice != null && x.price > maxPrice) continue;
      final conc = tagW.isEmpty
          ? 0.5
          : tagW.entries.fold<double>(0, (a, e) => a + (x.tag[e.key] ?? 0) * e.value) / tagSum;
      final qual = _skin.fold<double>(0, (a, s) => a + (x.quality[s] ?? 0) * (p.pSkin[s] ?? 0));
      out.add((x, weights[0] * conc + weights[1] * qual + weights[2] * knowPct[i]));
    }
    mergeSortDesc(out, (e) => e.$2);
    return out;
  }

  /// Tanpa kategori: 3 produk teratas tiap kategori. Dengan kategori: 10 teratas.
  List<Map<String, dynamic>> recommend(
    SkinProfile p, {
    String? category,
    int? maxPrice,
    int perCategory = 3,
    int limit = 10,
  }) {
    final s = score(p, category: category, maxPrice: maxPrice);
    List<(CatalogProduct, double)> picked;
    if (category == null) {
      picked = [
        for (final c in appCategories) ...s.where((e) => e.$1.category == c).take(perCategory),
      ];
      mergeSortDesc(picked, (e) => e.$2);
    } else {
      picked = s.take(limit).toList();
    }
    final items = [for (final e in picked) item(e.$1, e.$2, p)];
    _crossWarnings(items);
    return items;
  }

  /// Skor satu produk untuk profil (0 kalau diblokir filter keamanan).
  double scoreOf(String id, SkinProfile p) {
    for (final e in score(p)) {
      if (e.$1.id == id) return e.$2;
    }
    return 0;
  }

  // ------------------------------------------------------------ penjelasan
  Map<String, dynamic> item(CatalogProduct x, double score, SkinProfile p, {bool detail = false}) {
    final nv = needVector(p);
    final good = [for (final a in actives) if (nv.need[a]! > 0 && x.actives.contains(a)) a];
    mergeSortDesc(good, (a) => nv.need[a]!);
    final matched = {for (final a in good) ...?x.matched[a]}.toList()..sort();
    final reasons = <String>[];
    for (final a in good.take(3)) {
      final who = [...nv.src[a]!];
      mergeSortDesc(who, (t) => t.$2);
      final names = [
        for (final (t, w) in who.take(2))
          MlTexts.condition.containsKey(t.toLowerCase())
              ? '${MlTexts.condition[t.toLowerCase()]!.$1} (${(w * 100).round()}%)'
              : MlTexts.skin[t.toLowerCase()] ?? t.toLowerCase(),
      ];
      reasons.add(
        '$a: ${MlTexts.active[a] ?? 'Bahan aktif yang relevan'}. '
        'Cocok untuk ${names.join(' dan ')}.',
      );
    }
    final topSkin = _argmax(p.pSkin);
    final q = x.quality[topSkin] ?? 0;
    if (q >= 0.6) {
      final rating = x.rating == null
          ? 'rating -'
          : 'rating ${x.rating!.toStringAsFixed(1).replaceAll('.', ',')}';
      reasons.add(
        'Disukai ${MlTexts.skin[topSkin]}: lebih baik dari ${(q * 100).round()}% '
        'produk lain berdasarkan ulasan pengguna Sephora '
        '($rating dari ${_thousands(x.reviews)} ulasan).',
      );
    }
    return {
      'id': x.id,
      'name': x.name,
      'brand': x.brand,
      'category': x.category,
      'price': x.price,
      'match_score': (score * 1000).roundToDouble() / 1000,
      'image_url': null,
      'matched_ingredients': matched,
      'reasons': reasons,
      'warnings': _ownWarnings(x, p),
      if (detail) 'ingredients': x.ingredients,
      if (detail)
        'source_url':
            'https://www.sephora.com/search?keyword=${Uri.encodeQueryComponent('${x.brand} ${x.name}')}',
    };
  }

  List<String> _ownWarnings(CatalogProduct x, SkinProfile p) {
    final has = x.actives;
    return [
      if (has.contains('Retinol') && has.intersection({'AHA', 'Salicylic Acid', 'Benzoyl Peroxide'}).isNotEmpty)
        'Kombinasi kuat: Produk ini mengandung retinoid dan asam eksfolian/benzoyl '
            'peroxide sekaligus. Mulai 2–3 kali seminggu dan hentikan bila perih.',
      if (has.contains('Retinol') || has.contains('AHA'))
        'Pakai sunscreen: Retinoid dan AHA membuat kulit lebih sensitif terhadap matahari.',
      if (has.contains('Fragrance') && !p.sensitive)
        'Mengandung pewangi: Lakukan patch test dulu bila kulitmu mudah iritasi.',
    ];
  }

  /// Retinoid + produk ber-AHA/BHA di daftar yang sama.
  void _crossWarnings(List<Map<String, dynamic>> items) {
    for (final it in items) {
      if (!byId[it['id']]!.actives.contains('Retinol')) continue;
      final others = [
        for (final o in items)
          if (o['id'] != it['id'] &&
              byId[o['id']]!.actives.intersection({'AHA', 'Salicylic Acid'}).isNotEmpty)
            o['name'] as String,
      ];
      if (others.isNotEmpty) {
        (it['warnings'] as List<String>).add(
          'Jangan dipakai bersamaan dengan produk ber-AHA/BHA: Termasuk ${others.first} '
          'di daftar ini. Pakai di malam yang berbeda agar kulit tidak iritasi.',
        );
      }
    }
  }
}

String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

String _argmax(Map<String, double> m) {
  String? best;
  for (final e in m.entries) {
    if (best == null || e.value > m[best]!) best = e.key;
  }
  return best!;
}

String _thousands(int n) => n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');

/// Peringkat persentil seperti pandas `rank(pct=True)` (nilai sama -> rata-rata peringkat).
List<double> _rankPct(List<double> v) {
  final idx = List<int>.generate(v.length, (i) => i)..sort((a, b) => v[a].compareTo(v[b]));
  final out = List<double>.filled(v.length, 0);
  var i = 0;
  while (i < idx.length) {
    var j = i;
    while (j + 1 < idx.length && v[idx[j + 1]] == v[idx[i]]) {
      j++;
    }
    final r = (i + j) / 2 + 1;
    for (var k = i; k <= j; k++) {
      out[idx[k]] = r / v.length;
    }
    i = j + 1;
  }
  return out;
}
