// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analyze_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  age: (json['age'] as num).toInt(),
  gender: $enumDecode(_$GenderEnumMap, json['gender']),
  budgetMax: (json['budget_max'] as num).toInt(),
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'age': instance.age,
      'gender': _$GenderEnumMap[instance.gender]!,
      'budget_max': instance.budgetMax,
    };

const _$GenderEnumMap = {
  Gender.female: 'female',
  Gender.male: 'male',
  Gender.other: 'other',
};

_AnalyzePayload _$AnalyzePayloadFromJson(Map<String, dynamic> json) =>
    _AnalyzePayload(
      profile: UserProfile.fromJson(json['profile'] as Map<String, dynamic>),
      questionnaire: Map<String, int>.from(json['questionnaire'] as Map),
    );

Map<String, dynamic> _$AnalyzePayloadToJson(_AnalyzePayload instance) =>
    <String, dynamic>{
      'profile': instance.profile.toJson(),
      'questionnaire': instance.questionnaire,
    };
