import 'dart:convert';

import 'package:afaskin/data/models/models.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple flags and preferences (onboarding seen, consent, reminders).
abstract interface class FlagStore {
  bool get onboardingDone;
  Future<void> setOnboardingDone();

  bool get consentAccepted;
  Future<void> acceptConsent();

  /// In-app reminder to re-analyze every 2 weeks (on by default).
  bool get reminderOn;
  Future<void> setReminderOn({required bool on});

  /// Recommendations limited to the profile budget.
  bool get budgetFilterOn;
  Future<void> setBudgetFilterOn({required bool on});

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
  static const _reminderKey = 'reminder_on';
  static const _budgetFilterKey = 'budget_filter_on';
  static const Set<String> allowList = {
    _onboardingKey,
    _consentKey,
    _reminderKey,
    _budgetFilterKey,
  };

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
  bool get reminderOn => _prefs.getBool(_reminderKey) ?? true;
  @override
  Future<void> setReminderOn({required bool on}) =>
      _prefs.setBool(_reminderKey, on);

  @override
  bool get budgetFilterOn => _prefs.getBool(_budgetFilterKey) ?? false;
  @override
  Future<void> setBudgetFilterOn({required bool on}) =>
      _prefs.setBool(_budgetFilterKey, on);

  @override
  Future<void> clear() => _prefs.clear();
}

/// In-memory flags for tests.
class MemoryFlagStore implements FlagStore {
  MemoryFlagStore({
    this.onboardingDone = false,
    this.consentAccepted = false,
    this.reminderOn = true,
    this.budgetFilterOn = false,
  });

  @override
  bool onboardingDone;
  @override
  bool consentAccepted;
  @override
  bool reminderOn;
  @override
  bool budgetFilterOn;

  @override
  Future<void> setOnboardingDone() async => onboardingDone = true;
  @override
  Future<void> acceptConsent() async => consentAccepted = true;
  @override
  Future<void> setReminderOn({required bool on}) async => reminderOn = on;
  @override
  Future<void> setBudgetFilterOn({required bool on}) async =>
      budgetFilterOn = on;
  @override
  Future<void> clear() async {
    onboardingDone = false;
    consentAccepted = false;
    reminderOn = true;
    budgetFilterOn = false;
  }
}

/// Nickname, profile, questionnaire answers and favorites, stored in the
/// Hive `user` box as JSON strings (schema-free; no TypeAdapters needed).
/// The nickname never leaves the phone.
abstract interface class UserStore {
  String? readName();
  Future<void> writeName(String name);

  UserProfile? readProfile();
  Future<void> writeProfile(UserProfile profile);

  QuestionnaireAnswers? readAnswers();
  Future<void> writeAnswers(QuestionnaireAnswers answers);

  Set<String> readFavorites();
  Future<void> writeFavorites(Set<String> productIds);

  Future<void> clear();
}

/// Saved questionnaire answers plus the questionnaire version they belong to.
class QuestionnaireAnswers {
  const QuestionnaireAnswers({
    required this.version,
    required this.answers,
    this.answeredAt,
  });

  factory QuestionnaireAnswers.fromJson(Map<String, dynamic> json) =>
      QuestionnaireAnswers(
        version: json['version'] as String,
        answers: (json['answers'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, v as int),
        ),
        answeredAt: DateTime.tryParse('${json['answered_at']}'),
      );

  final String version;
  final Map<String, int> answers;

  /// When the user last answered (shown in the re-analyze sheet).
  final DateTime? answeredAt;

  Map<String, dynamic> toJson() => {
    'version': version,
    'answers': answers,
    if (answeredAt != null) 'answered_at': answeredAt!.toIso8601String(),
  };
}

class HiveUserStore implements UserStore {
  HiveUserStore(this._box);

  static const String boxName = 'user';
  static const _nameKey = 'name';
  static const _profileKey = 'profile';
  static const _answersKey = 'questionnaire';
  static const _favoritesKey = 'favorites';

  final Box<String> _box;

  Object? _read(String key) {
    final raw = _box.get(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }

  @override
  String? readName() => _box.get(_nameKey);

  @override
  Future<void> writeName(String name) => _box.put(_nameKey, name);

  @override
  UserProfile? readProfile() {
    final json = _read(_profileKey);
    return json is Map<String, dynamic> ? UserProfile.fromJson(json) : null;
  }

  @override
  Future<void> writeProfile(UserProfile profile) =>
      _box.put(_profileKey, jsonEncode(profile.toJson()));

  @override
  QuestionnaireAnswers? readAnswers() {
    final json = _read(_answersKey);
    return json is Map<String, dynamic>
        ? QuestionnaireAnswers.fromJson(json)
        : null;
  }

  @override
  Future<void> writeAnswers(QuestionnaireAnswers answers) =>
      _box.put(_answersKey, jsonEncode(answers.toJson()));

  @override
  Set<String> readFavorites() {
    final json = _read(_favoritesKey);
    return json is List ? {for (final e in json) '$e'} : <String>{};
  }

  @override
  Future<void> writeFavorites(Set<String> productIds) =>
      _box.put(_favoritesKey, jsonEncode(productIds.toList()));

  @override
  Future<void> clear() => _box.clear();
}

/// In-memory store for tests.
class MemoryUserStore implements UserStore {
  String? name;
  UserProfile? profile;
  QuestionnaireAnswers? answers;
  Set<String> favorites = {};

  @override
  String? readName() => name;
  @override
  Future<void> writeName(String n) async => name = n;
  @override
  UserProfile? readProfile() => profile;
  @override
  Future<void> writeProfile(UserProfile p) async => profile = p;
  @override
  QuestionnaireAnswers? readAnswers() => answers;
  @override
  Future<void> writeAnswers(QuestionnaireAnswers a) async => answers = a;
  @override
  Set<String> readFavorites() => favorites;
  @override
  Future<void> writeFavorites(Set<String> ids) async => favorites = {...ids};
  @override
  Future<void> clear() async {
    name = null;
    profile = null;
    answers = null;
    favorites = {};
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
