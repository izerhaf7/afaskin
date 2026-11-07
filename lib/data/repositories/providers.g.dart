// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fusion profiles per analysis. `main.dart` overrides this with the Hive box.

@ProviderFor(profileStore)
final profileStoreProvider = ProfileStoreProvider._();

/// Fusion profiles per analysis. `main.dart` overrides this with the Hive box.

final class ProfileStoreProvider
    extends $FunctionalProvider<ProfileStore, ProfileStore, ProfileStore>
    with $Provider<ProfileStore> {
  /// Fusion profiles per analysis. `main.dart` overrides this with the Hive box.
  ProfileStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileStoreHash();

  @$internal
  @override
  $ProviderElement<ProfileStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProfileStore create(Ref ref) {
    return profileStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileStore>(value),
    );
  }
}

String _$profileStoreHash() => r'd8af23ebdeb598aa95f38145383b3cf195164a79';

/// On-device ML (TFLite models + catalog), loaded once in the background.

@ProviderFor(mlEngine)
final mlEngineProvider = MlEngineProvider._();

/// On-device ML (TFLite models + catalog), loaded once in the background.

final class MlEngineProvider
    extends
        $FunctionalProvider<AsyncValue<MlEngine>, MlEngine, FutureOr<MlEngine>>
    with $FutureModifier<MlEngine>, $FutureProvider<MlEngine> {
  /// On-device ML (TFLite models + catalog), loaded once in the background.
  MlEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mlEngineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mlEngineHash();

  @$internal
  @override
  $FutureProviderElement<MlEngine> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<MlEngine> create(Ref ref) {
    return mlEngine(ref);
  }
}

String _$mlEngineHash() => r'e656b30e7649a229c0ef689299d1596e1217d66a';

/// On-device analysis (default) or canned mock responses (`USE_MOCK=true`).
/// Widgets read this provider, never the engine directly.

@ProviderFor(analysisRepository)
final analysisRepositoryProvider = AnalysisRepositoryProvider._();

/// On-device analysis (default) or canned mock responses (`USE_MOCK=true`).
/// Widgets read this provider, never the engine directly.

final class AnalysisRepositoryProvider
    extends
        $FunctionalProvider<
          AnalysisRepository,
          AnalysisRepository,
          AnalysisRepository
        >
    with $Provider<AnalysisRepository> {
  /// On-device analysis (default) or canned mock responses (`USE_MOCK=true`).
  /// Widgets read this provider, never the engine directly.
  AnalysisRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analysisRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analysisRepositoryHash();

  @$internal
  @override
  $ProviderElement<AnalysisRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AnalysisRepository create(Ref ref) {
    return analysisRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnalysisRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnalysisRepository>(value),
    );
  }
}

String _$analysisRepositoryHash() =>
    r'9d9f01c1be7c4f227676af18ec303be6f6b671b0';
