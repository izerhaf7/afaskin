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
    await session.saveNameAndAge(' Rani ', 21);
    // Gender and budget are not part of setup.
    expect(container.read(sessionProvider).nextStep, SetupStep.questionnaire);
    expect(container.read(sessionProvider).profileComplete, isFalse);
    await session.saveAnswers(
      const QuestionnaireAnswers(version: '2026-11', answers: {'q1': 5}),
    );

    expect(container.read(sessionProvider).isSetupComplete, isTrue);
    expect(flags.onboardingDone && flags.consentAccepted, isTrue);
    expect(user.name, 'Rani');
    expect(user.profile, const UserProfile(age: 21));
    expect(user.answers!.answers, {'q1': 5});
    expect(container.read(sessionProvider).initial, 'R');
  });

  test('nickname is required before the questionnaire', () async {
    final session = container.read(sessionProvider.notifier);
    await session.completeOnboarding();
    await session.acceptConsent();
    user.profile = const UserProfile(age: 30);
    container.invalidate(sessionProvider);
    expect(container.read(sessionProvider).nextStep, SetupStep.profile);
    expect(container.read(sessionProvider).initial, 'A');
  });

  test('completeProfile keeps age and turns the budget filter on', () async {
    final session = container.read(sessionProvider.notifier);
    await session.saveNameAndAge('Rani', 23);
    await session.completeProfile(Gender.female, 150000);
    final s = container.read(sessionProvider);
    expect(
      s.profile,
      const UserProfile(age: 23, gender: Gender.female, budgetMax: 150000),
    );
    expect(s.profileComplete, isTrue);
    expect(s.activeBudget, 150000);
    expect(flags.budgetFilterOn, isTrue);

    await session.setBudgetFilter(null);
    expect(container.read(sessionProvider).activeBudget, isNull);
    // Budget value is kept for next time.
    expect(container.read(sessionProvider).profile!.budgetMax, 150000);

    await session.setBudgetFilter(300000);
    expect(container.read(sessionProvider).activeBudget, 300000);
  });

  test('favorites toggle and persist; reminder flag persists', () async {
    final session = container.read(sessionProvider.notifier);
    expect(await session.toggleFavorite('prd_004'), isTrue);
    expect(user.favorites, {'prd_004'});
    expect(await session.toggleFavorite('prd_004'), isFalse);
    expect(user.favorites, isEmpty);

    expect(container.read(sessionProvider).reminderOn, isTrue);
    await session.setReminder(on: false);
    expect(flags.reminderOn, isFalse);
    expect(container.read(sessionProvider).reminderOn, isFalse);
  });

  test('state is restored from stores on startup', () {
    flags
      ..onboardingDone = true
      ..consentAccepted = true;
    user
      ..name = 'Budi'
      ..profile = const UserProfile(
        age: 30,
        gender: Gender.unspecified,
        budgetMax: 50000,
      );
    expect(container.read(sessionProvider).nextStep, SetupStep.questionnaire);
    expect(container.read(sessionProvider).name, 'Budi');
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
