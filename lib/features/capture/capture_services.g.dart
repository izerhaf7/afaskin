// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capture_services.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cameraPermission)
final cameraPermissionProvider = CameraPermissionProvider._();

final class CameraPermissionProvider
    extends
        $FunctionalProvider<
          CameraPermissionService,
          CameraPermissionService,
          CameraPermissionService
        >
    with $Provider<CameraPermissionService> {
  CameraPermissionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cameraPermissionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cameraPermissionHash();

  @$internal
  @override
  $ProviderElement<CameraPermissionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CameraPermissionService create(Ref ref) {
    return cameraPermission(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CameraPermissionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CameraPermissionService>(value),
    );
  }
}

String _$cameraPermissionHash() => r'9362425cd660d10b89cda7f482280b3919bb0e06';

@ProviderFor(galleryPicker)
final galleryPickerProvider = GalleryPickerProvider._();

final class GalleryPickerProvider
    extends $FunctionalProvider<GalleryPicker, GalleryPicker, GalleryPicker>
    with $Provider<GalleryPicker> {
  GalleryPickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'galleryPickerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$galleryPickerHash();

  @$internal
  @override
  $ProviderElement<GalleryPicker> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GalleryPicker create(Ref ref) {
    return galleryPicker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GalleryPicker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GalleryPicker>(value),
    );
  }
}

String _$galleryPickerHash() => r'949115850f899b32b2d1ff37a9653fffcb942cb7';
