import 'package:afaskin/core/config/env.dart';
import 'package:afaskin/core/network/dio_client.dart';
import 'package:afaskin/data/repositories/analysis_repository.dart';
import 'package:afaskin/data/repositories/analysis_repository_api.dart';
import 'package:afaskin/data/repositories/analysis_repository_mock.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
Dio dio(Ref ref) => buildDio();

/// Mock vs API is picked with `--dart-define=USE_MOCK=true|false`.
/// Widgets read this provider, never `dio` directly.
@Riverpod(keepAlive: true)
AnalysisRepository analysisRepository(Ref ref) {
  if (Env.useMock) {
    return AnalysisRepositoryMock(
      rootBundle,
      scenario: MockScenario.parse(Env.mockScenario),
    );
  }
  return AnalysisRepositoryApi(ref.watch(dioProvider), rootBundle);
}
