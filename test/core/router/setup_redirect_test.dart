import 'package:afaskin/core/router/app_router.dart';
import 'package:afaskin/core/session/session_controller.dart';
import 'package:afaskin/data/local/local_stores.dart';
import 'package:afaskin/data/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

const _profile = UserProfile(age: 21, gender: Gender.female, budgetMax: 150000);
const _answers = QuestionnaireAnswers(version: 'v', answers: {'q1': 3});

void main() {
  const fresh = SessionState(onboardingDone: false, consentAccepted: false);
  const consentPending = SessionState(
    onboardingDone: true,
    consentAccepted: false,
  );
  const done = SessionState(
    onboardingDone: true,
    consentAccepted: true,
    name: 'Rani',
    profile: _profile,
    answers: _answers,
  );

  test('nextStep follows the setup order', () {
    expect(fresh.nextStep, SetupStep.onboarding);
    expect(consentPending.nextStep, SetupStep.consent);
    expect(
      const SessionState(onboardingDone: true, consentAccepted: true).nextStep,
      SetupStep.profile,
    );
    expect(
      const SessionState(
        onboardingDone: true,
        consentAccepted: true,
        name: 'Rani',
        profile: _profile,
      ).nextStep,
      SetupStep.questionnaire,
    );
    expect(done.nextStep, isNull);
  });

  test('splash is always allowed', () {
    expect(setupRedirect(fresh, AppRoutes.splash), isNull);
    expect(setupRedirect(done, AppRoutes.splash), isNull);
  });

  test('cannot skip consent or reach the app before setup', () {
    expect(setupRedirect(consentPending, AppRoutes.home), AppRoutes.consent);
    expect(
      setupRedirect(consentPending, AppRoutes.setupProfile),
      AppRoutes.consent,
    );
    expect(setupRedirect(consentPending, AppRoutes.capture), AppRoutes.consent);
    expect(setupRedirect(consentPending, AppRoutes.consent), isNull);
    // Going back to an earlier step is fine.
    expect(setupRedirect(consentPending, AppRoutes.onboarding), isNull);
  });

  test('after setup, setup routes bounce home; app routes pass', () {
    expect(setupRedirect(done, AppRoutes.onboarding), AppRoutes.home);
    expect(setupRedirect(done, AppRoutes.setupQuestionnaire), AppRoutes.home);
    expect(setupRedirect(done, AppRoutes.home), isNull);
    expect(setupRedirect(done, AppRoutes.editQuestionnaire), isNull);
  });
}
