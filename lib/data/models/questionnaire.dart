import 'package:freezed_annotation/freezed_annotation.dart';

part 'questionnaire.freezed.dart';
part 'questionnaire.g.dart';

/// `GET /questionnaire`. Content is still a draft, so it is always fetched
/// (with a bundled fallback) rather than hardcoded.
@freezed
abstract class Questionnaire with _$Questionnaire {
  const factory Questionnaire({
    required String version,
    required List<Question> questions,
  }) = _Questionnaire;

  factory Questionnaire.fromJson(Map<String, dynamic> json) =>
      _$QuestionnaireFromJson(json);
}

@freezed
abstract class Question with _$Question {
  const factory Question({
    required String id,
    required String text,
    required LikertScale scale,
  }) = _Question;

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);
}

@freezed
abstract class LikertScale with _$LikertScale {
  const factory LikertScale({
    required int min,
    required int max,
    required String minLabel,
    required String maxLabel,
  }) = _LikertScale;

  const LikertScale._();

  factory LikertScale.fromJson(Map<String, dynamic> json) =>
      _$LikertScaleFromJson(json);

  /// All selectable values, e.g. `[1, 2, 3, 4, 5]`.
  List<int> get values => [for (var v = min; v <= max; v++) v];
}
