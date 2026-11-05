// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridden in `main.dart` (and tests) with the opened Hive box.

@ProviderFor(historyStore)
final historyStoreProvider = HistoryStoreProvider._();

/// Overridden in `main.dart` (and tests) with the opened Hive box.

final class HistoryStoreProvider
    extends $FunctionalProvider<HistoryStore, HistoryStore, HistoryStore>
    with $Provider<HistoryStore> {
  /// Overridden in `main.dart` (and tests) with the opened Hive box.
  HistoryStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyStoreHash();

  @$internal
  @override
  $ProviderElement<HistoryStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HistoryStore create(Ref ref) {
    return historyStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HistoryStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HistoryStore>(value),
    );
  }
}

String _$historyStoreHash() => r'3999e8069d6ab203ca97efa3b392e132e904aefc';

@ProviderFor(History)
final historyProvider = HistoryProvider._();

final class HistoryProvider
    extends $NotifierProvider<History, List<AnalysisResult>> {
  HistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyHash();

  @$internal
  @override
  History create() => History();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<AnalysisResult> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<AnalysisResult>>(value),
    );
  }
}

String _$historyHash() => r'ce0355c6feadd57dff15b0ded57fa99459965997';

abstract class _$History extends $Notifier<List<AnalysisResult>> {
  List<AnalysisResult> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<AnalysisResult>, List<AnalysisResult>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<AnalysisResult>, List<AnalysisResult>>,
              List<AnalysisResult>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
