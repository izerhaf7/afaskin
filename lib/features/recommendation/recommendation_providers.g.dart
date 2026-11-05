// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(recommendations)
final recommendationsProvider = RecommendationsFamily._();

final class RecommendationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Product>>,
          List<Product>,
          FutureOr<List<Product>>
        >
    with $FutureModifier<List<Product>>, $FutureProvider<List<Product>> {
  RecommendationsProvider._({
    required RecommendationsFamily super.from,
    required ({String analysisId, ProductCategory? category, int? maxPrice})
    super.argument,
  }) : super(
         retry: null,
         name: r'recommendationsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recommendationsHash();

  @override
  String toString() {
    return r'recommendationsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Product>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Product>> create(Ref ref) {
    final argument =
        this.argument
            as ({String analysisId, ProductCategory? category, int? maxPrice});
    return recommendations(
      ref,
      analysisId: argument.analysisId,
      category: argument.category,
      maxPrice: argument.maxPrice,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RecommendationsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recommendationsHash() => r'161cd828e49c84b92c049dc0b4cd70fe7d31361c';

final class RecommendationsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Product>>,
          ({String analysisId, ProductCategory? category, int? maxPrice})
        > {
  RecommendationsFamily._()
    : super(
        retry: null,
        name: r'recommendationsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RecommendationsProvider call({
    required String analysisId,
    ProductCategory? category,
    int? maxPrice,
  }) => RecommendationsProvider._(
    argument: (analysisId: analysisId, category: category, maxPrice: maxPrice),
    from: this,
  );

  @override
  String toString() => r'recommendationsProvider';
}

@ProviderFor(productDetail)
final productDetailProvider = ProductDetailFamily._();

final class ProductDetailProvider
    extends $FunctionalProvider<AsyncValue<Product>, Product, FutureOr<Product>>
    with $FutureModifier<Product>, $FutureProvider<Product> {
  ProductDetailProvider._({
    required ProductDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'productDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$productDetailHash();

  @override
  String toString() {
    return r'productDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Product> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Product> create(Ref ref) {
    final argument = this.argument as String;
    return productDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProductDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$productDetailHash() => r'0258764d23972e5de045199af9b742bd5da78657';

final class ProductDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Product>, String> {
  ProductDetailFamily._()
    : super(
        retry: null,
        name: r'productDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProductDetailProvider call(String id) =>
      ProductDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'productDetailProvider';
}
