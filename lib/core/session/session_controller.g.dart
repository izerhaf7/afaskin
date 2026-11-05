// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridden in `main.dart` (and in tests) with the real stores.

@ProviderFor(flagStore)
final flagStoreProvider = FlagStoreProvider._();

/// Overridden in `main.dart` (and in tests) with the real stores.

final class FlagStoreProvider
    extends $FunctionalProvider<FlagStore, FlagStore, FlagStore>
    with $Provider<FlagStore> {
  /// Overridden in `main.dart` (and in tests) with the real stores.
  FlagStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'flagStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$flagStoreHash();

  @$internal
  @override
  $ProviderElement<FlagStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FlagStore create(Ref ref) {
    return flagStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlagStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlagStore>(value),
    );
  }
}

String _$flagStoreHash() => r'b5eac746c086a1644c5b04d6c2bbcdf68b6cf24a';

@ProviderFor(userStore)
final userStoreProvider = UserStoreProvider._();

final class UserStoreProvider
    extends $FunctionalProvider<UserStore, UserStore, UserStore>
    with $Provider<UserStore> {
  UserStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userStoreHash();

  @$internal
  @override
  $ProviderElement<UserStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserStore create(Ref ref) {
    return userStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserStore>(value),
    );
  }
}

String _$userStoreHash() => r'a8a6d9e1314a27586d7e88154c5e459ed057282c';

/// App-wide user state. Reads synchronously at startup (stores are opened in
/// `main` before `runApp`), so the router can decide immediately.

@ProviderFor(Session)
final sessionProvider = SessionProvider._();

/// App-wide user state. Reads synchronously at startup (stores are opened in
/// `main` before `runApp`), so the router can decide immediately.
final class SessionProvider extends $NotifierProvider<Session, SessionState> {
  /// App-wide user state. Reads synchronously at startup (stores are opened in
  /// `main` before `runApp`), so the router can decide immediately.
  SessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionHash();

  @$internal
  @override
  Session create() => Session();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionState>(value),
    );
  }
}

String _$sessionHash() => r'48ec20d0242fbbc8d93103753f3ee618f76b53b7';

/// App-wide user state. Reads synchronously at startup (stores are opened in
/// `main` before `runApp`), so the router can decide immediately.

abstract class _$Session extends $Notifier<SessionState> {
  SessionState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SessionState, SessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SessionState, SessionState>,
              SessionState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
