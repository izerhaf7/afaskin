import 'package:afaskin/data/local/local_stores.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_controller.g.dart';

/// Overridden in `main.dart` (and in tests) with the real stores.
@Riverpod(keepAlive: true)
FlagStore flagStore(Ref ref) =>
    throw UnimplementedError('flagStoreProvider must be overridden');

@Riverpod(keepAlive: true)
UserStore userStore(Ref ref) =>
    throw UnimplementedError('userStoreProvider must be overridden');

/// Setup steps, in the order the user must complete them.
/// Gender and budget are not part of setup: they are asked after the first
/// result ("Lengkapi profilmu").
enum SetupStep { onboarding, consent, profile, questionnaire }

/// Minimum age (design: "Afa Skin untuk pengguna 17 tahun ke atas").
const int kMinAge = 17;
const int kMaxAge = 99;

class SessionState {
  const SessionState({
    required this.onboardingDone,
    required this.consentAccepted,
    this.name,
    this.profile,
    this.answers,
    this.reminderOn = true,
    this.budgetFilterOn = false,
    this.favorites = const {},
  });

  final bool onboardingDone;
  final bool consentAccepted;

  /// Nickname. Local only, never sent to the server.
  final String? name;
  final UserProfile? profile;
  final QuestionnaireAnswers? answers;
  final bool reminderOn;

  /// Recommendations limited to `profile.budgetMax`.
  final bool budgetFilterOn;
  final Set<String> favorites;

  /// First unfinished step, or null when the user can use the main app.
  SetupStep? get nextStep {
    if (!onboardingDone) return SetupStep.onboarding;
    if (!consentAccepted) return SetupStep.consent;
    if ((name ?? '').trim().isEmpty || profile == null) {
      return SetupStep.profile;
    }
    if (answers == null) return SetupStep.questionnaire;
    return null;
  }

  bool get isSetupComplete => nextStep == null;

  /// Gender and budget answered.
  bool get profileComplete => profile?.isComplete ?? false;

  /// Budget used to filter recommendations, or null for "Semua harga".
  int? get activeBudget => budgetFilterOn ? profile?.budgetMax : null;

  /// Avatar letter: first letter of the nickname, "A" before it is known.
  String get initial {
    final n = (name ?? '').trim();
    return n.isEmpty ? 'A' : n.substring(0, 1).toUpperCase();
  }

  SessionState copyWith({
    bool? onboardingDone,
    bool? consentAccepted,
    String? name,
    UserProfile? profile,
    QuestionnaireAnswers? answers,
    bool? reminderOn,
    bool? budgetFilterOn,
    Set<String>? favorites,
  }) => SessionState(
    onboardingDone: onboardingDone ?? this.onboardingDone,
    consentAccepted: consentAccepted ?? this.consentAccepted,
    name: name ?? this.name,
    profile: profile ?? this.profile,
    answers: answers ?? this.answers,
    reminderOn: reminderOn ?? this.reminderOn,
    budgetFilterOn: budgetFilterOn ?? this.budgetFilterOn,
    favorites: favorites ?? this.favorites,
  );
}

/// App-wide user state. Reads synchronously at startup (stores are opened in
/// `main` before `runApp`), so the router can decide immediately.
@Riverpod(keepAlive: true)
class Session extends _$Session {
  FlagStore get _flags => ref.read(flagStoreProvider);
  UserStore get _user => ref.read(userStoreProvider);

  @override
  SessionState build() => SessionState(
    onboardingDone: _flags.onboardingDone,
    consentAccepted: _flags.consentAccepted,
    name: _user.readName(),
    profile: _user.readProfile(),
    answers: _user.readAnswers(),
    reminderOn: _flags.reminderOn,
    budgetFilterOn: _flags.budgetFilterOn,
    favorites: _user.readFavorites(),
  );

  Future<void> completeOnboarding() async {
    await _flags.setOnboardingDone();
    state = state.copyWith(onboardingDone: true);
  }

  Future<void> acceptConsent() async {
    await _flags.acceptConsent();
    state = state.copyWith(consentAccepted: true);
  }

  /// Setup step: nickname + age. Keeps gender/budget if already known.
  Future<void> saveNameAndAge(String name, int age) async {
    final profile = (state.profile ?? UserProfile(age: age)).copyWith(age: age);
    await _user.writeName(name.trim());
    await _user.writeProfile(profile);
    state = state.copyWith(name: name.trim(), profile: profile);
  }

  /// "Lengkapi profilmu": gender + budget. Turns the budget filter on.
  Future<void> completeProfile(Gender gender, int budgetMax) async {
    final base = state.profile ?? const UserProfile(age: kMinAge);
    final profile = base.copyWith(gender: gender, budgetMax: budgetMax);
    await _user.writeProfile(profile);
    await _flags.setBudgetFilterOn(on: true);
    state = state.copyWith(profile: profile, budgetFilterOn: true);
  }

  /// Full edit from Settings.
  Future<void> saveProfile(String name, UserProfile profile) async {
    await _user.writeName(name.trim());
    await _user.writeProfile(profile);
    state = state.copyWith(name: name.trim(), profile: profile);
  }

  /// Budget sheet: null = "Semua harga" (filter off).
  Future<void> setBudgetFilter(int? budgetMax) async {
    if (budgetMax == null) {
      await _flags.setBudgetFilterOn(on: false);
      state = state.copyWith(budgetFilterOn: false);
      return;
    }
    final base = state.profile ?? const UserProfile(age: kMinAge);
    final profile = base.copyWith(budgetMax: budgetMax);
    await _user.writeProfile(profile);
    await _flags.setBudgetFilterOn(on: true);
    state = state.copyWith(profile: profile, budgetFilterOn: true);
  }

  Future<void> saveAnswers(QuestionnaireAnswers answers) async {
    await _user.writeAnswers(answers);
    state = state.copyWith(answers: answers);
  }

  Future<void> setReminder({required bool on}) async {
    await _flags.setReminderOn(on: on);
    state = state.copyWith(reminderOn: on);
  }

  /// Returns true when the product is now a favorite.
  Future<bool> toggleFavorite(String productId) async {
    final next = {...state.favorites};
    final added = next.add(productId);
    if (!added) next.remove(productId);
    await _user.writeFavorites(next);
    state = state.copyWith(favorites: next);
    return added;
  }

  /// Wipes flags, profile, answers and favorites (Settings).
  Future<void> clearAll() async {
    await _flags.clear();
    await _user.clear();
    state = const SessionState(onboardingDone: false, consentAccepted: false);
  }
}
