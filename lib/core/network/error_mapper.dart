import 'package:dio/dio.dart';

import 'package:afaskin/core/network/failures.dart';

/// Maps any error from the HTTP layer to a domain [Failure].
Failure mapToFailure(Object error) {
  if (error is Failure) return error;
  if (error is! DioException) return const ServerFailure();

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const NetworkFailure(isTimeout: true);
    case DioExceptionType.connectionError:
    case DioExceptionType.badCertificate:
      return const NetworkFailure();
    case DioExceptionType.badResponse:
      return _fromResponse(error.response);
    case DioExceptionType.cancel:
    case DioExceptionType.unknown:
      // `unknown` usually wraps a SocketException when offline.
      return error.response != null
          ? _fromResponse(error.response)
          : const NetworkFailure();
  }
}

Failure _fromResponse(Response<dynamic>? response) {
  final status = response?.statusCode;
  final data = response?.data;

  if (status == 422 && data is Map && data['error'] == 'quality_rejected') {
    final reasons = data['reasons'];
    return QualityRejected(
      reasons: reasons is List ? reasons.map((e) => '$e').toList() : const [],
      serverMessage: data['message'] is String
          ? data['message'] as String
          : null,
    );
  }
  return ServerFailure(statusCode: status);
}
