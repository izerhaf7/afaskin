import 'dart:convert';

import 'package:afaskin/ml/fusion.dart';
import 'package:hive_ce/hive_ce.dart';

/// Profil hasil fusion per analisis, disimpan di HP supaya rekomendasi bisa
/// dihitung ulang (filter kategori/budget) tanpa menganalisis foto lagi.
abstract interface class ProfileStore {
  SkinProfile? read(String analysisId);

  /// Profil dari analisis terbaru (untuk halaman detail produk).
  SkinProfile? latest();
  Future<void> save(String analysisId, SkinProfile profile, DateTime createdAt);
  Future<void> clear();
}

class HiveProfileStore implements ProfileStore {
  HiveProfileStore(this._box);

  static const String boxName = 'analysis_profiles';
  final Box<String> _box;

  Map<String, dynamic>? _raw(String id) {
    final s = _box.get(id);
    return s == null ? null : jsonDecode(s) as Map<String, dynamic>;
  }

  @override
  SkinProfile? read(String analysisId) {
    final r = _raw(analysisId);
    return r == null ? null : SkinProfile.fromJson((r['profile'] as Map).cast<String, dynamic>());
  }

  @override
  SkinProfile? latest() {
    Map<String, dynamic>? best;
    for (final k in _box.keys) {
      final r = _raw(k as String);
      if (r != null && (best == null || (r['created_at'] as String).compareTo(best['created_at'] as String) > 0)) {
        best = r;
      }
    }
    return best == null ? null : SkinProfile.fromJson((best['profile'] as Map).cast<String, dynamic>());
  }

  @override
  Future<void> save(String analysisId, SkinProfile profile, DateTime createdAt) => _box.put(
    analysisId,
    jsonEncode({'profile': profile.toJson(), 'created_at': createdAt.toIso8601String()}),
  );

  @override
  Future<void> clear() => _box.clear();
}

class MemoryProfileStore implements ProfileStore {
  final _items = <String, (SkinProfile, DateTime)>{};

  @override
  SkinProfile? read(String analysisId) => _items[analysisId]?.$1;

  @override
  SkinProfile? latest() {
    (SkinProfile, DateTime)? best;
    for (final v in _items.values) {
      if (best == null || v.$2.isAfter(best.$2)) best = v;
    }
    return best?.$1;
  }

  @override
  Future<void> save(String analysisId, SkinProfile profile, DateTime createdAt) async =>
      _items[analysisId] = (profile, createdAt);

  @override
  Future<void> clear() async => _items.clear();
}
