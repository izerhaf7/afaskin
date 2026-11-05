import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:afaskin/data/models/enums.dart';

part 'product.freezed.dart';
part 'product.g.dart';

/// A recommended product. The same model serves both
/// `GET /recommendations` items and `GET /products/{id}`; the detail-only
/// fields ([ingredients], [sourceUrl]) are null in list items.
@freezed
abstract class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    required String brand,
    @JsonKey(unknownEnumValue: ProductCategory.unknown)
    required ProductCategory category,

    /// Rupiah.
    required int price,
    required double matchScore,
    String? imageUrl,
    @Default(<String>[]) List<String> matchedIngredients,
    @Default(<String>[]) List<String> reasons,

    /// Active-ingredient conflict warnings, e.g. retinol + AHA.
    @Default(<String>[]) List<String> warnings,

    // Detail only.
    List<String>? ingredients,
    String? sourceUrl,
  }) = _Product;

  const Product._();

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  bool get hasWarnings => warnings.isNotEmpty;

  bool isMatchedIngredient(String ingredient) {
    final i = ingredient.toLowerCase().trim();
    return matchedIngredients.any((m) => i.contains(m.toLowerCase().trim()));
  }
}

/// `GET /recommendations`
@freezed
abstract class RecommendationList with _$RecommendationList {
  const factory RecommendationList({required List<Product> items}) =
      _RecommendationList;

  factory RecommendationList.fromJson(Map<String, dynamic> json) =>
      _$RecommendationListFromJson(json);
}
