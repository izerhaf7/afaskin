import 'package:afaskin/core/l10n/app_strings.dart';

/// Domain-level errors. Repositories throw these; the UI never sees
/// `DioException` and can switch over the sealed type.
sealed class Failure implements Exception {
  const Failure(this.message);

  /// Friendly Indonesian message, safe to show as-is.
  final String message;

  @override
  String toString() => 'Failure: $message';
}

/// No connection, DNS failure, timeout, TLS error, etc.
final class NetworkFailure extends Failure {
  const NetworkFailure({this.isTimeout = false})
    : super(isTimeout ? AppStrings.errorTimeout : AppStrings.errorNetwork);

  final bool isTimeout;
}

/// The server's quality gate rejected the photo (HTTP 422,
/// `error: quality_rejected`). The UI should send the user back to the camera.
final class QualityRejected extends Failure {
  const QualityRejected({required this.reasons, String? serverMessage})
    : super(serverMessage ?? AppStrings.errorQualityDefault);

  /// Machine codes, e.g. `too_dark`, `blurry`.
  final List<String> reasons;

  /// Reasons translated for display; unknown codes are kept verbatim.
  List<String> get readableReasons => [
    for (final r in reasons) AppStrings.qualityReasons[r] ?? r,
  ];
}

/// Any other non-success response or an unparseable body.
final class ServerFailure extends Failure {
  const ServerFailure({this.statusCode, String? message})
    : super(message ?? AppStrings.errorServer);

  final int? statusCode;
}
