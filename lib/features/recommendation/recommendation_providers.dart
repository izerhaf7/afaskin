import 'package:afaskin/data/models/models.dart';
import 'package:afaskin/data/repositories/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recommendation_providers.g.dart';

@riverpod
Future<List<Product>> recommendations(
  Ref ref, {
  required String analysisId,
  ProductCategory? category,
  int? maxPrice,
}) => ref
    .watch(analysisRepositoryProvider)
    .getRecommendations(
      analysisId: analysisId,
      category: category,
      maxPrice: maxPrice,
    );

@riverpod
Future<Product> productDetail(Ref ref, String id) =>
    ref.watch(analysisRepositoryProvider).getProduct(id);
