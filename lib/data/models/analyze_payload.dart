import 'package:afaskin/data/models/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'analyze_payload.freezed.dart';
part 'analyze_payload.g.dart';

/// The `profile` part of the analyze payload. Gender and budget are asked
/// after the first result ("Lengkapi profilmu"), so they can be null; they
/// are then sent as JSON `null`.
@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required int age,
    Gender? gender,

    /// Max price per product, in Rupiah.
    int? budgetMax,
  }) = _UserProfile;

  const UserProfile._();

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  /// Gender and budget both answered.
  bool get isComplete => gender != null && budgetMax != null;
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
