// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'questionnaire.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Questionnaire _$QuestionnaireFromJson(Map<String, dynamic> json) =>
    _Questionnaire(
      version: json['version'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$QuestionnaireToJson(_Questionnaire instance) =>
    <String, dynamic>{
      'version': instance.version,
      'questions': instance.questions.map((e) => e.toJson()).toList(),
    };

_Question _$QuestionFromJson(Map<String, dynamic> json) => _Question(
  id: json['id'] as String,
  text: json['text'] as String,
  scale: LikertScale.fromJson(json['scale'] as Map<String, dynamic>),
);

Map<String, dynamic> _$QuestionToJson(_Question instance) => <String, dynamic>{
  'id': instance.id,
  'text': instance.text,
  'scale': instance.scale.toJson(),
};

_LikertScale _$LikertScaleFromJson(Map<String, dynamic> json) => _LikertScale(
  min: (json['min'] as num).toInt(),
  max: (json['max'] as num).toInt(),
  minLabel: json['min_label'] as String,
  maxLabel: json['max_label'] as String,
);

Map<String, dynamic> _$LikertScaleToJson(_LikertScale instance) =>
    <String, dynamic>{
      'min': instance.min,
      'max': instance.max,
      'min_label': instance.minLabel,
      'max_label': instance.maxLabel,
    };
