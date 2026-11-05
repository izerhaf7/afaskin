import 'dart:convert';
import 'dart:io';

import 'package:afaskin/data/local/local_stores.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';

final _base = AnalysisResult.fromJson(
  jsonDecode(File('assets/mock/analyze_success.json').readAsStringSync())
      as Map<String, dynamic>,
);

AnalysisResult _at(String id, DateTime t) =>
    _base.copyWith(analysisId: id, createdAt: t);

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('afaskin_hive');
    Hive.init(dir.path);
  });

  tearDown(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  test('history: newest first, delete, clear, survives reopen', () async {
    var box = await Hive.openBox<String>(HiveHistoryStore.boxName);
    var store = HiveHistoryStore(box);
    await store.save(_at('a', DateTime.utc(2026, 11)));
    await store.save(_at('b', DateTime.utc(2026, 11, 3)));
    await store.save(_at('c', DateTime.utc(2026, 11, 2)));
    expect(store.readAll().map((r) => r.analysisId), ['b', 'c', 'a']);

    // Persisted to disk.
    await box.close();
    box = await Hive.openBox<String>(HiveHistoryStore.boxName);
    store = HiveHistoryStore(box);
    expect(store.readAll(), hasLength(3));
    expect(store.readAll().first.conditions, isNotEmpty);

    await store.delete('c');
    expect(store.readAll().map((r) => r.analysisId), ['b', 'a']);
    await store.clear();
    expect(store.readAll(), isEmpty);
  });

  test('history: corrupt entries are skipped, not fatal', () async {
    final box = await Hive.openBox<String>(HiveHistoryStore.boxName);
    await box.put('bad', '{not json');
    await box.put('old', jsonEncode({'analysis_id': 'x'}));
    final store = HiveHistoryStore(box);
    await store.save(_at('ok', DateTime.utc(2026)));
    expect(store.readAll().map((r) => r.analysisId), ['ok']);
  });

  test('history stores only result JSON (no image data)', () async {
    final box = await Hive.openBox<String>(HiveHistoryStore.boxName);
    await HiveHistoryStore(box).save(_at('a', DateTime.utc(2026)));
    final raw = jsonDecode(box.get('a')!) as Map<String, dynamic>;
    expect(raw.keys, isNot(contains('image')));
    expect(raw.keys.toSet(), _base.toJson().keys.toSet());
  });

  test('user store round trip', () async {
    final box = await Hive.openBox<String>(HiveUserStore.boxName);
    final store = HiveUserStore(box);
    expect(store.readProfile(), isNull);
    const p = UserProfile(age: 22, gender: Gender.male, budgetMax: 250000);
    await store.writeProfile(p);
    await store.writeAnswers(
      const QuestionnaireAnswers(version: 'v', answers: {'q1': 3}),
    );
    expect(store.readProfile(), p);
    expect(store.readAnswers()!.answers, {'q1': 3});
    await store.clear();
    expect(store.readProfile(), isNull);
  });
}
