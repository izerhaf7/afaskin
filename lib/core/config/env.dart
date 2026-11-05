/// Build-time configuration, passed with `--dart-define`.
///
/// ```bash
/// flutter run --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=https://api.example.com
/// ```
abstract final class Env {
  /// Backend root, without the `/api/v1` prefix.
  /// Default points at a FastAPI dev server on the host machine as seen from
  /// the Android emulator.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  /// Read responses from `assets/mock/` instead of the network.
  /// Defaults to `true` while the backend is not ready.
  static const bool useMock = bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: true,
  );

  /// Mock-only: `success` or `quality_fail` (makes `/analyze` return 422).
  static const String mockScenario = String.fromEnvironment(
    'MOCK_SCENARIO',
    defaultValue: 'success',
  );

  static const String apiPrefix = '/api/v1';
}
