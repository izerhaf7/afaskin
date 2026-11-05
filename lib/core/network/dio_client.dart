import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:afaskin/core/config/env.dart';

/// Builds the app's single [Dio] instance.
///
/// - 30 s timeouts (analysis target is < 5 s, but cold servers are slow).
/// - Request/response logging in debug builds only.
/// - Simple retry for idempotent GETs on connection problems.
/// - Refuses non-HTTPS base URLs in release builds.
Dio buildDio({String baseUrl = Env.apiBaseUrl}) {
  if (kReleaseMode && !baseUrl.startsWith('https://')) {
    throw StateError('Release builds require an HTTPS API_BASE_URL.');
  }

  final dio = Dio(
    BaseOptions(
      baseUrl: '$baseUrl${Env.apiPrefix}',
      connectTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      responseType: ResponseType.json,
      headers: {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(RetryInterceptor(dio));
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: false, // never log the photo upload
        responseBody: true,
        logPrint: (o) => debugPrint('[dio] $o'),
      ),
    );
  }
  return dio;
}

/// Retries GET requests that failed before reaching the server.
///
/// POST `/analyze` is never retried automatically: a multipart body can only
/// be sent once, and the user gets an explicit "Coba lagi" button instead.
class RetryInterceptor extends Interceptor {
  RetryInterceptor(
    this._dio, {
    this.maxRetries = 2,
    this.baseDelay = const Duration(milliseconds: 500),
  });

  final Dio _dio;
  final int maxRetries;
  final Duration baseDelay;

  static const _attemptKey = 'retry_attempt';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final attempt = (options.extra[_attemptKey] as int?) ?? 0;

    if (!_shouldRetry(err) || attempt >= maxRetries) {
      return handler.next(err);
    }

    await Future<void>.delayed(baseDelay * (1 << attempt));
    options.extra[_attemptKey] = attempt + 1;
    try {
      final response = await _dio.fetch<dynamic>(options);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  bool _shouldRetry(DioException err) {
    if (err.requestOptions.method.toUpperCase() != 'GET') return false;
    return switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.connectionError ||
      DioExceptionType.receiveTimeout => true,
      _ => false,
    };
  }
}
