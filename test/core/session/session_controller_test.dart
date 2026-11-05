import 'package:afaskin/core/session/session_controller.dart';
import 'package:afaskin/data/local/local_stores.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MemoryFlagStore flags;
  late MemoryUserStore user;
  late ProviderContainer container;

  setUp(() {
    flags = MemoryFlagStore();
    user = MemoryUserStore();
    container = ProviderContainer(
      overrides: [
        flagStoreProvider.overrideWithValue(flags),
        userStoreProvider.overrideWithValue(user),
      ],
    );
    addTearDown(container.dispose);
  });

  test('walks through setup and persists every step', () async {
    final session = container.read(sessionProvider.notifier);
    expect(container.read(sessionProvider).nextStep, SetupStep.onboarding);

    await session.completeOnboarding();
    await session.acceptConsent();
    const profile = UserProfile(
      age: 21,
      gender: Gender.male,
      budgetMax: 100000,
    );
    await session.saveProfile(profile);
    await session.saveAnswers(
      const QuestionnaireAnswers(version: '2026-11', answers: {'q1': 5}),
    );

    expect(container.read(sessionProvider).isSetupComplete, isTrue);
    expect(flags.onboardingDone && flags.consentAccepted, isTrue);
    expect(user.profile, profile);
    expect(user.answers!.answers, {'q1': 5});
  });

  test('state is restored from stores on startup', () {
    flags
      ..onboardingDone = true
      ..consentAccepted = true;
    user.profile = const UserProfile(
      age: 30,
      gender: Gender.other,
      budgetMax: 50000,
    );
    expect(container.read(sessionProvider).nextStep, SetupStep.questionnaire);
  });

  test('clearAll resets to onboarding', () async {
    final session = container.read(sessionProvider.notifier);
    await session.completeOnboarding();
    await session.clearAll();
    expect(container.read(sessionProvider).nextStep, SetupStep.onboarding);
    expect(flags.onboardingDone, isFalse);
  });

  test('QuestionnaireAnswers JSON round trip', () {
    const a = QuestionnaireAnswers(version: 'v1', answers: {'q1': 2, 'q7': 4});
    final b = QuestionnaireAnswers.fromJson(a.toJson());
    expect(b.version, 'v1');
    expect(b.answers, {'q1': 2, 'q7': 4});
  });
}
