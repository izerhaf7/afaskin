import 'package:afaskin/data/local/local_stores.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'history_controller.g.dart';

/// Overridden in `main.dart` (and tests) with the opened Hive box.
@Riverpod(keepAlive: true)
HistoryStore historyStore(Ref ref) =>
    throw UnimplementedError('historyStoreProvider must be overridden');

@Riverpod(keepAlive: true)
class History extends _$History {
  HistoryStore get _store => ref.read(historyStoreProvider);

  @override
  List<AnalysisResult> build() => _store.readAll();

  Future<void> add(AnalysisResult result) async {
    await _store.save(result);
    state = _store.readAll();
  }

  Future<void> remove(String analysisId) async {
    await _store.delete(analysisId);
    state = _store.readAll();
  }

  Future<void> clear() async {
    await _store.clear();
    state = const [];
  }

  AnalysisResult? byId(String id) =>
      state.where((r) => r.analysisId == id).firstOrNull;
}
