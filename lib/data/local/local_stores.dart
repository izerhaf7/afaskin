import 'dart:convert';

import 'package:afaskin/data/models/models.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple flags (onboarding seen, consent accepted).
abstract interface class FlagStore {
  bool get onboardingDone;
  Future<void> setOnboardingDone();

  bool get consentAccepted;
  Future<void> acceptConsent();

  Future<void> clear();
}

/// Bump when the consent text changes materially: users must accept again.
const String currentConsentVersion = '2026-11';

/// [FlagStore] backed by SharedPreferences.
class PrefsFlagStore implements FlagStore {
  PrefsFlagStore(this._prefs);

  final SharedPreferencesWithCache _prefs;

  static const _onboardingKey = 'onboarding_done';
  static const _consentKey = 'consent_version';
  static const Set<String> allowList = {_onboardingKey, _consentKey};

  @override
  bool get onboardingDone => _prefs.getBool(_onboardingKey) ?? false;
  @override
  Future<void> setOnboardingDone() => _prefs.setBool(_onboardingKey, true);

  @override
  bool get consentAccepted =>
      _prefs.getString(_consentKey) == currentConsentVersion;
  @override
  Future<void> acceptConsent() =>
      _prefs.setString(_consentKey, currentConsentVersion);

  @override
  Future<void> clear() => _prefs.clear();
}

/// In-memory flags for tests.
class MemoryFlagStore implements FlagStore {
  MemoryFlagStore({this.onboardingDone = false, this.consentAccepted = false});

  @override
  bool onboardingDone;
  @override
  bool consentAccepted;

  @override
  Future<void> setOnboardingDone() async => onboardingDone = true;
  @override
  Future<void> acceptConsent() async => consentAccepted = true;
  @override
  Future<void> clear() async {
    onboardingDone = false;
    consentAccepted = false;
  }
}

/// Profile and questionnaire answers, stored in the Hive `user` box as JSON
/// strings (keeps the box schema-free; no TypeAdapters needed).
abstract interface class UserStore {
  UserProfile? readProfile();
  Future<void> writeProfile(UserProfile profile);

  QuestionnaireAnswers? readAnswers();
  Future<void> writeAnswers(QuestionnaireAnswers answers);

  Future<void> clear();
}

/// Saved questionnaire answers plus the questionnaire version they belong to.
class QuestionnaireAnswers {
  const QuestionnaireAnswers({required this.version, required this.answers});

  factory QuestionnaireAnswers.fromJson(Map<String, dynamic> json) =>
      QuestionnaireAnswers(
        version: json['version'] as String,
        answers: (json['answers'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, v as int),
        ),
      );

  final String version;
  final Map<String, int> answers;

  Map<String, dynamic> toJson() => {'version': version, 'answers': answers};
}

class HiveUserStore implements UserStore {
  HiveUserStore(this._box);

  static const String boxName = 'user';
  static const _profileKey = 'profile';
  static const _answersKey = 'questionnaire';

  final Box<String> _box;

  Map<String, dynamic>? _read(String key) {
    final raw = _box.get(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } on FormatException {
      return null;
    }
  }

  @override
  UserProfile? readProfile() {
    final json = _read(_profileKey);
    return json == null ? null : UserProfile.fromJson(json);
  }

  @override
  Future<void> writeProfile(UserProfile profile) =>
      _box.put(_profileKey, jsonEncode(profile.toJson()));

  @override
  QuestionnaireAnswers? readAnswers() {
    final json = _read(_answersKey);
    return json == null ? null : QuestionnaireAnswers.fromJson(json);
  }

  @override
  Future<void> writeAnswers(QuestionnaireAnswers answers) =>
      _box.put(_answersKey, jsonEncode(answers.toJson()));

  @override
  Future<void> clear() => _box.clear();
}

/// In-memory store for tests.
class MemoryUserStore implements UserStore {
  UserProfile? profile;
  QuestionnaireAnswers? answers;

  @override
  UserProfile? readProfile() => profile;
  @override
  Future<void> writeProfile(UserProfile p) async => profile = p;
  @override
  QuestionnaireAnswers? readAnswers() => answers;
  @override
  Future<void> writeAnswers(QuestionnaireAnswers a) async => answers = a;
  @override
  Future<void> clear() async {
    profile = null;
    answers = null;
  }
}

/// Past analyses (result JSON only, never the photo), newest first.
abstract interface class HistoryStore {
  List<AnalysisResult> readAll();
  Future<void> save(AnalysisResult result);
  Future<void> delete(String analysisId);
  Future<void> clear();
}

List<AnalysisResult> _newestFirst(Iterable<AnalysisResult> items) =>
    items.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

class HiveHistoryStore implements HistoryStore {
  HiveHistoryStore(this._box);

  static const String boxName = 'history';

  final Box<String> _box;

  @override
  List<AnalysisResult> readAll() {
    final items = <AnalysisResult>[];
    for (final raw in _box.values) {
      try {
        items.add(
          AnalysisResult.fromJson(jsonDecode(raw) as Map<String, dynamic>),
        );
      } on Object {
        // Skip entries written by an older, incompatible app version.
      }
    }
    return _newestFirst(items);
  }

  @override
  Future<void> save(AnalysisResult result) =>
      _box.put(result.analysisId, jsonEncode(result.toJson()));

  @override
  Future<void> delete(String analysisId) => _box.delete(analysisId);

  @override
  Future<void> clear() => _box.clear();
}

class MemoryHistoryStore implements HistoryStore {
  final Map<String, AnalysisResult> items = {};

  @override
  List<AnalysisResult> readAll() => _newestFirst(items.values);
  @override
  Future<void> save(AnalysisResult r) async => items[r.analysisId] = r;
  @override
  Future<void> delete(String id) async => items.remove(id);
  @override
  Future<void> clear() async => items.clear();
}
