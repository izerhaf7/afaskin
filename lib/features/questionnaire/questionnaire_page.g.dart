// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'questionnaire_page.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Questions come from `GET /questionnaire` (bundled fallback in the repo).

@ProviderFor(questionnaire)
final questionnaireProvider = QuestionnaireProvider._();

/// Questions come from `GET /questionnaire` (bundled fallback in the repo).

final class QuestionnaireProvider
    extends
        $FunctionalProvider<
          AsyncValue<Questionnaire>,
          Questionnaire,
          FutureOr<Questionnaire>
        >
    with $FutureModifier<Questionnaire>, $FutureProvider<Questionnaire> {
  /// Questions come from `GET /questionnaire` (bundled fallback in the repo).
  QuestionnaireProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'questionnaireProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$questionnaireHash();

  @$internal
  @override
  $FutureProviderElement<Questionnaire> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Questionnaire> create(Ref ref) {
    return questionnaire(ref);
  }
}

String _$questionnaireHash() => r'6f3c056e72ed55979ec68db8b28feed4addb5910';
