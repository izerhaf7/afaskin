/// Build-time configuration, passed with `--dart-define`.
///
/// The app analyzes photos fully on the device (no server, no internet):
///
/// ```bash
/// flutter run                                          # analisis on-device (default)
/// flutter run --dart-define=COND_MODEL=ResNet50       # model kondisi yang lebih akurat tapi lebih lambat
/// flutter run --dart-define=USE_MOCK=true             # respons contoh dari assets/mock/ (untuk desain/test)
/// ```
abstract final class Env {
  /// Read canned responses from `assets/mock/` instead of running the models.
  static const bool useMock = bool.fromEnvironment('USE_MOCK');

  /// Mock-only: `success` or `quality_fail` (makes analyze reject the photo).
  static const String mockScenario = String.fromEnvironment(
    'MOCK_SCENARIO',
    defaultValue: 'success',
  );

  /// Condition model architecture (`MobileNetV2` or `ResNet50`). Empty = the
  /// default in `assets/ml/ml_config.json`.
  static const String conditionModel = String.fromEnvironment('COND_MODEL');

  /// Developer diagnostics: writes the photos, face landmarks and raw model
  /// outputs of each analysis to the app's external files dir
  /// (`/sdcard/Android/data/<app>/files/ml_debug/`). Never enable for users.
  static const bool mlDebug = bool.fromEnvironment('ML_DEBUG');
}
