import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:afaskin/data/models/enums.dart';

part 'analyze_payload.freezed.dart';
part 'analyze_payload.g.dart';

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required int age,
    required Gender gender,

    /// Max price per product, in Rupiah.
    required int budgetMax,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

/// The `payload` form field of `POST /analyze` (sent as a JSON string).
@freezed
abstract class AnalyzePayload with _$AnalyzePayload {
  const factory AnalyzePayload({
    required UserProfile profile,

    /// Question id -> Likert answer, e.g. `{"q1": 4}`.
    required Map<String, int> questionnaire,
  }) = _AnalyzePayload;

  factory AnalyzePayload.fromJson(Map<String, dynamic> json) =>
      _$AnalyzePayloadFromJson(json);
}
