// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Product {

 String get id; String get name; String get brand;@JsonKey(unknownEnumValue: ProductCategory.unknown) ProductCategory get category;/// Rupiah.
 int get price; double get matchScore; String? get imageUrl; List<String> get matchedIngredients; List<String> get reasons;/// Active-ingredient conflict warnings, e.g. retinol + AHA.
 List<String> get warnings; List<String>? get ingredients; String? get sourceUrl;
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCopyWith<Product> get copyWith => _$ProductCopyWithImpl<Product>(this as Product, _$identity);

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Product;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Product&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.brand, _this.brand) || other.brand == _this.brand)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.matchScore, _this.matchScore) || other.matchScore == _this.matchScore)&&(identical(other.imageUrl, _this.imageUrl) || other.imageUrl == _this.imageUrl)&&const DeepCollectionEquality().equals(other.matchedIngredients, _this.matchedIngredients)&&const DeepCollectionEquality().equals(other.reasons, _this.reasons)&&const DeepCollectionEquality().equals(other.warnings, _this.warnings)&&const DeepCollectionEquality().equals(other.ingredients, _this.ingredients)&&(identical(other.sourceUrl, _this.sourceUrl) || other.sourceUrl == _this.sourceUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Product;
  return Object.hash(runtimeType,_this.id,_this.name,_this.brand,_this.category,_this.price,_this.matchScore,_this.imageUrl,const DeepCollectionEquality().hash(_this.matchedIngredients),const DeepCollectionEquality().hash(_this.reasons),const DeepCollectionEquality().hash(_this.warnings),const DeepCollectionEquality().hash(_this.ingredients),_this.sourceUrl);
}

@override
String toString() {
  final _this = this as Product;
  return 'Product(id: ${_this.id}, name: ${_this.name}, brand: ${_this.brand}, category: ${_this.category}, price: ${_this.price}, matchScore: ${_this.matchScore}, imageUrl: ${_this.imageUrl}, matchedIngredients: ${_this.matchedIngredients}, reasons: ${_this.reasons}, warnings: ${_this.warnings}, ingredients: ${_this.ingredients}, sourceUrl: ${_this.sourceUrl})';
}


}

/// @nodoc
abstract mixin class $ProductCopyWith<$Res>  {
  factory $ProductCopyWith(Product value, $Res Function(Product) _then) = _$ProductCopyWithImpl;
@useResult
$Res call({
 String id, String name, String brand,@JsonKey(unknownEnumValue: ProductCategory.unknown) ProductCategory category, int price, double matchScore, String? imageUrl, List<String> matchedIngredients, List<String> reasons, List<String> warnings, List<String>? ingredients, String? sourceUrl
});




}
/// @nodoc
class _$ProductCopyWithImpl<$Res>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._self, this._then);

  final Product _self;
  final $Res Function(Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? brand = null,Object? category = null,Object? price = null,Object? matchScore = null,Object? imageUrl = freezed,Object? matchedIngredients = null,Object? reasons = null,Object? warnings = null,Object? ingredients = freezed,Object? sourceUrl = freezed,}) {
  return _then(Product(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ProductCategory,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int,matchScore: null == matchScore ? _self.matchScore : matchScore // ignore: cast_nullable_to_non_nullable
as double,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,matchedIngredients: null == matchedIngredients ? _self.matchedIngredients : matchedIngredients // ignore: cast_nullable_to_non_nullable
as List<String>,reasons: null == reasons ? _self.reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<String>,warnings: null == warnings ? _self.warnings : warnings // ignore: cast_nullable_to_non_nullable
as List<String>,ingredients: freezed == ingredients ? _self.ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<String>?,sourceUrl: freezed == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Product].
extension ProductPatterns on Product {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Product value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Product value)  $default,){
final _that = this;
switch (_that) {
case _Product():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Product value)?  $default,){
final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String brand, @JsonKey(unknownEnumValue: ProductCategory.unknown)  ProductCategory category,  int price,  double matchScore,  String? imageUrl,  List<String> matchedIngredients,  List<String> reasons,  List<String> warnings,  List<String>? ingredients,  String? sourceUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.name,_that.brand,_that.category,_that.price,_that.matchScore,_that.imageUrl,_that.matchedIngredients,_that.reasons,_that.warnings,_that.ingredients,_that.sourceUrl);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String brand, @JsonKey(unknownEnumValue: ProductCategory.unknown)  ProductCategory category,  int price,  double matchScore,  String? imageUrl,  List<String> matchedIngredients,  List<String> reasons,  List<String> warnings,  List<String>? ingredients,  String? sourceUrl)  $default,) {final _that = this;
switch (_that) {
case _Product():
return $default(_that.id,_that.name,_that.brand,_that.category,_that.price,_that.matchScore,_that.imageUrl,_that.matchedIngredients,_that.reasons,_that.warnings,_that.ingredients,_that.sourceUrl);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String brand, @JsonKey(unknownEnumValue: ProductCategory.unknown)  ProductCategory category,  int price,  double matchScore,  String? imageUrl,  List<String> matchedIngredients,  List<String> reasons,  List<String> warnings,  List<String>? ingredients,  String? sourceUrl)?  $default,) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.name,_that.brand,_that.category,_that.price,_that.matchScore,_that.imageUrl,_that.matchedIngredients,_that.reasons,_that.warnings,_that.ingredients,_that.sourceUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Product extends Product {
  const _Product({required this.id, required this.name, required this.brand, @JsonKey(unknownEnumValue: ProductCategory.unknown) required this.category, required this.price, required this.matchScore, this.imageUrl,  List<String> matchedIngredients = const <String>[],  List<String> reasons = const <String>[],  List<String> warnings = const <String>[],  List<String>? ingredients, this.sourceUrl}): _matchedIngredients = matchedIngredients,_reasons = reasons,_warnings = warnings,_ingredients = ingredients,super._();
  factory _Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

@override final  String id;
@override final  String name;
@override final  String brand;
@override@JsonKey(unknownEnumValue: ProductCategory.unknown) final  ProductCategory category;
/// Rupiah.
@override final  int price;
@override final  double matchScore;
@override final  String? imageUrl;
 final  List<String> _matchedIngredients;
@override@JsonKey() List<String> get matchedIngredients {
  if (_matchedIngredients is EqualUnmodifiableListView) return _matchedIngredients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_matchedIngredients);
}

 final  List<String> _reasons;
@override@JsonKey() List<String> get reasons {
  if (_reasons is EqualUnmodifiableListView) return _reasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reasons);
}

/// Active-ingredient conflict warnings, e.g. retinol + AHA.
 final  List<String> _warnings;
/// Active-ingredient conflict warnings, e.g. retinol + AHA.
@override@JsonKey() List<String> get warnings {
  if (_warnings is EqualUnmodifiableListView) return _warnings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_warnings);
}

 final  List<String>? _ingredients;
@override List<String>? get ingredients {
  final value = _ingredients;
  if (value == null) return null;
  if (_ingredients is EqualUnmodifiableListView) return _ingredients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? sourceUrl;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCopyWith<_Product> get copyWith => __$ProductCopyWithImpl<_Product>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Product&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.category, category) || other.category == category)&&(identical(other.price, price) || other.price == price)&&(identical(other.matchScore, matchScore) || other.matchScore == matchScore)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other.matchedIngredients, _matchedIngredients)&&const DeepCollectionEquality().equals(other.reasons, _reasons)&&const DeepCollectionEquality().equals(other.warnings, _warnings)&&const DeepCollectionEquality().equals(other.ingredients, _ingredients)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,brand,category,price,matchScore,imageUrl,const DeepCollectionEquality().hash(_matchedIngredients),const DeepCollectionEquality().hash(_reasons),const DeepCollectionEquality().hash(_warnings),const DeepCollectionEquality().hash(_ingredients),sourceUrl);
}

@override
String toString() {
    return 'Product(id: $id, name: $name, brand: $brand, category: $category, price: $price, matchScore: $matchScore, imageUrl: $imageUrl, matchedIngredients: $matchedIngredients, reasons: $reasons, warnings: $warnings, ingredients: $ingredients, sourceUrl: $sourceUrl)';
}


}

/// @nodoc
abstract mixin class _$ProductCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$ProductCopyWith(_Product value, $Res Function(_Product) _then) = __$ProductCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String brand,@JsonKey(unknownEnumValue: ProductCategory.unknown) ProductCategory category, int price, double matchScore, String? imageUrl, List<String> matchedIngredients, List<String> reasons, List<String> warnings, List<String>? ingredients, String? sourceUrl
});




}
/// @nodoc
class __$ProductCopyWithImpl<$Res>
    implements _$ProductCopyWith<$Res> {
  __$ProductCopyWithImpl(this._self, this._then);

  final _Product _self;
  final $Res Function(_Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? brand = null,Object? category = null,Object? price = null,Object? matchScore = null,Object? imageUrl = freezed,Object? matchedIngredients = null,Object? reasons = null,Object? warnings = null,Object? ingredients = freezed,Object? sourceUrl = freezed,}) {
  return _then(_Product(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ProductCategory,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int,matchScore: null == matchScore ? _self.matchScore : matchScore // ignore: cast_nullable_to_non_nullable
as double,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,matchedIngredients: null == matchedIngredients ? _self._matchedIngredients : matchedIngredients // ignore: cast_nullable_to_non_nullable
as List<String>,reasons: null == reasons ? _self._reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<String>,warnings: null == warnings ? _self._warnings : warnings // ignore: cast_nullable_to_non_nullable
as List<String>,ingredients: freezed == ingredients ? _self._ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<String>?,sourceUrl: freezed == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$RecommendationList {

 List<Product> get items;
/// Create a copy of RecommendationList
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecommendationListCopyWith<RecommendationList> get copyWith => _$RecommendationListCopyWithImpl<RecommendationList>(this as RecommendationList, _$identity);

  /// Serializes this RecommendationList to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RecommendationList;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecommendationList&&const DeepCollectionEquality().equals(other.items, _this.items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RecommendationList;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.items));
}

@override
String toString() {
  final _this = this as RecommendationList;
  return 'RecommendationList(items: ${_this.items})';
}


}

/// @nodoc
abstract mixin class $RecommendationListCopyWith<$Res>  {
  factory $RecommendationListCopyWith(RecommendationList value, $Res Function(RecommendationList) _then) = _$RecommendationListCopyWithImpl;
@useResult
$Res call({
 List<Product> items
});




}
/// @nodoc
class _$RecommendationListCopyWithImpl<$Res>
    implements $RecommendationListCopyWith<$Res> {
  _$RecommendationListCopyWithImpl(this._self, this._then);

  final RecommendationList _self;
  final $Res Function(RecommendationList) _then;

/// Create a copy of RecommendationList
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,}) {
  return _then(RecommendationList(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Product>,
  ));
}

}


/// Adds pattern-matching-related methods to [RecommendationList].
extension RecommendationListPatterns on RecommendationList {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecommendationList value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecommendationList() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecommendationList value)  $default,){
final _that = this;
switch (_that) {
case _RecommendationList():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecommendationList value)?  $default,){
final _that = this;
switch (_that) {
case _RecommendationList() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Product> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecommendationList() when $default != null:
return $default(_that.items);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Product> items)  $default,) {final _that = this;
switch (_that) {
case _RecommendationList():
return $default(_that.items);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Product> items)?  $default,) {final _that = this;
switch (_that) {
case _RecommendationList() when $default != null:
return $default(_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecommendationList implements RecommendationList {
  const _RecommendationList({required  List<Product> items}): _items = items;
  factory _RecommendationList.fromJson(Map<String, dynamic> json) => _$RecommendationListFromJson(json);

 final  List<Product> _items;
@override List<Product> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of RecommendationList
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecommendationListCopyWith<_RecommendationList> get copyWith => __$RecommendationListCopyWithImpl<_RecommendationList>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecommendationListToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecommendationList&&const DeepCollectionEquality().equals(other.items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));
}

@override
String toString() {
    return 'RecommendationList(items: $items)';
}


}

/// @nodoc
abstract mixin class _$RecommendationListCopyWith<$Res> implements $RecommendationListCopyWith<$Res> {
  factory _$RecommendationListCopyWith(_RecommendationList value, $Res Function(_RecommendationList) _then) = __$RecommendationListCopyWithImpl;
@override @useResult
$Res call({
 List<Product> items
});




}
/// @nodoc
class __$RecommendationListCopyWithImpl<$Res>
    implements _$RecommendationListCopyWith<$Res> {
  __$RecommendationListCopyWithImpl(this._self, this._then);

  final _RecommendationList _self;
  final $Res Function(_RecommendationList) _then;

/// Create a copy of RecommendationList
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,}) {
  return _then(_RecommendationList(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Product>,
  ));
}


}

// dart format on
