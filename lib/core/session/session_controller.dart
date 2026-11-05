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
enum SetupStep { onboarding, consent, profile, questionnaire }

class SessionState {
  const SessionState({
    required this.onboardingDone,
    required this.consentAccepted,
    this.profile,
    this.answers,
  });

  final bool onboardingDone;
  final bool consentAccepted;
  final UserProfile? profile;
  final QuestionnaireAnswers? answers;

  /// First unfinished step, or null when the user can use the main app.
  SetupStep? get nextStep {
    if (!onboardingDone) return SetupStep.onboarding;
    if (!consentAccepted) return SetupStep.consent;
    if (profile == null) return SetupStep.profile;
    if (answers == null) return SetupStep.questionnaire;
    return null;
  }

  bool get isSetupComplete => nextStep == null;

  SessionState copyWith({
    bool? onboardingDone,
    bool? consentAccepted,
    UserProfile? profile,
    QuestionnaireAnswers? answers,
  }) => SessionState(
    onboardingDone: onboardingDone ?? this.onboardingDone,
    consentAccepted: consentAccepted ?? this.consentAccepted,
    profile: profile ?? this.profile,
    answers: answers ?? this.answers,
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
    profile: _user.readProfile(),
    answers: _user.readAnswers(),
  );

  Future<void> completeOnboarding() async {
    await _flags.setOnboardingDone();
    state = state.copyWith(onboardingDone: true);
  }

  Future<void> acceptConsent() async {
    await _flags.acceptConsent();
    state = state.copyWith(consentAccepted: true);
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _user.writeProfile(profile);
    state = state.copyWith(profile: profile);
  }

  Future<void> saveAnswers(QuestionnaireAnswers answers) async {
    await _user.writeAnswers(answers);
    state = state.copyWith(answers: answers);
  }

  /// Wipes flags, profile and answers (Settings > hapus semua data).
  Future<void> clearAll() async {
    await _flags.clear();
    await _user.clear();
    state = const SessionState(onboardingDone: false, consentAccepted: false);
  }
}
