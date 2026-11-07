import 'package:afaskin/core/config/env.dart';
import 'package:afaskin/data/repositories/analysis_repository.dart';
import 'package:afaskin/data/repositories/analysis_repository_local.dart';
import 'package:afaskin/data/repositories/analysis_repository_mock.dart';
import 'package:afaskin/ml/ml_engine.dart';
import 'package:afaskin/ml/profile_store.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

/// Fusion profiles per analysis. `main.dart` overrides this with the Hive box.
@Riverpod(keepAlive: true)
ProfileStore profileStore(Ref ref) => MemoryProfileStore();

/// On-device ML (TFLite models + catalog), loaded once in the background.
@Riverpod(keepAlive: true)
Future<MlEngine> mlEngine(Ref ref) async {
  final engine = await MlEngine.load(rootBundle, conditionModel: Env.conditionModel);
  ref.onDispose(engine.dispose);
  return engine;
}

/// On-device analysis (default) or canned mock responses (`USE_MOCK=true`).
/// Widgets read this provider, never the engine directly.
@Riverpod(keepAlive: true)
AnalysisRepository analysisRepository(Ref ref) {
  if (Env.useMock) {
    return AnalysisRepositoryMock(
      rootBundle,
      scenario: MockScenario.parse(Env.mockScenario),
    );
  }
  return AnalysisRepositoryLocal(
    engine: ref.watch(mlEngineProvider.future),
    profiles: ref.watch(profileStoreProvider),
    bundle: rootBundle,
  );
}
