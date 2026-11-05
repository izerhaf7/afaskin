// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: json['id'] as String,
  name: json['name'] as String,
  brand: json['brand'] as String,
  category: $enumDecode(
    _$ProductCategoryEnumMap,
    json['category'],
    unknownValue: ProductCategory.unknown,
  ),
  price: (json['price'] as num).toInt(),
  matchScore: (json['match_score'] as num).toDouble(),
  imageUrl: json['image_url'] as String?,
  matchedIngredients:
      (json['matched_ingredients'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  reasons:
      (json['reasons'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  warnings:
      (json['warnings'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  ingredients: (json['ingredients'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  sourceUrl: json['source_url'] as String?,
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'brand': instance.brand,
  'category': _$ProductCategoryEnumMap[instance.category]!,
  'price': instance.price,
  'match_score': instance.matchScore,
  'image_url': instance.imageUrl,
  'matched_ingredients': instance.matchedIngredients,
  'reasons': instance.reasons,
  'warnings': instance.warnings,
  'ingredients': instance.ingredients,
  'source_url': instance.sourceUrl,
};

const _$ProductCategoryEnumMap = {
  ProductCategory.cleanser: 'cleanser',
  ProductCategory.toner: 'toner',
  ProductCategory.serum: 'serum',
  ProductCategory.moisturizer: 'moisturizer',
  ProductCategory.sunscreen: 'sunscreen',
  ProductCategory.unknown: 'unknown',
};

_RecommendationList _$RecommendationListFromJson(Map<String, dynamic> json) =>
    _RecommendationList(
      items: (json['items'] as List<dynamic>)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RecommendationListToJson(_RecommendationList instance) =>
    <String, dynamic>{'items': instance.items.map((e) => e.toJson()).toList()};
