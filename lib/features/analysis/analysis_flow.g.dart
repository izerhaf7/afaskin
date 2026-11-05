// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_flow.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The processed (resized, EXIF-free) JPEG waiting to be analyzed.
/// Memory only: never written to disk, cleared once the server has it.

@ProviderFor(PendingPhoto)
final pendingPhotoProvider = PendingPhotoProvider._();

/// The processed (resized, EXIF-free) JPEG waiting to be analyzed.
/// Memory only: never written to disk, cleared once the server has it.
final class PendingPhotoProvider
    extends $NotifierProvider<PendingPhoto, Uint8List?> {
  /// The processed (resized, EXIF-free) JPEG waiting to be analyzed.
  /// Memory only: never written to disk, cleared once the server has it.
  PendingPhotoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingPhotoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingPhotoHash();

  @$internal
  @override
  PendingPhoto create() => PendingPhoto();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Uint8List? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Uint8List?>(value),
    );
  }
}

String _$pendingPhotoHash() => r'4c58d530f9b143e98c4715b703da484aab6a4bb2';

/// The processed (resized, EXIF-free) JPEG waiting to be analyzed.
/// Memory only: never written to disk, cleared once the server has it.

abstract class _$PendingPhoto extends $Notifier<Uint8List?> {
  Uint8List? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Uint8List?, Uint8List?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Uint8List?, Uint8List?>,
              Uint8List?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Result of the most recent analysis, shown on the result screen.

@ProviderFor(LatestAnalysis)
final latestAnalysisProvider = LatestAnalysisProvider._();

/// Result of the most recent analysis, shown on the result screen.
final class LatestAnalysisProvider
    extends $NotifierProvider<LatestAnalysis, AnalysisResult?> {
  /// Result of the most recent analysis, shown on the result screen.
  LatestAnalysisProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'latestAnalysisProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$latestAnalysisHash();

  @$internal
  @override
  LatestAnalysis create() => LatestAnalysis();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnalysisResult? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnalysisResult?>(value),
    );
  }
}

String _$latestAnalysisHash() => r'211eb49c2eb432c66b8803129ba55880f6cf0ab0';

/// Result of the most recent analysis, shown on the result screen.

abstract class _$LatestAnalysis extends $Notifier<AnalysisResult?> {
  AnalysisResult? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AnalysisResult?, AnalysisResult?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AnalysisResult?, AnalysisResult?>,
              AnalysisResult?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
