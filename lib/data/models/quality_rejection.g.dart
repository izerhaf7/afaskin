// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quality_rejection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QualityRejectionBody _$QualityRejectionBodyFromJson(
  Map<String, dynamic> json,
) => _QualityRejectionBody(
  error: json['error'] as String,
  reasons:
      (json['reasons'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  message: json['message'] as String?,
);

Map<String, dynamic> _$QualityRejectionBodyToJson(
  _QualityRejectionBody instance,
) => <String, dynamic>{
  'error': instance.error,
  'reasons': instance.reasons,
  'message': instance.message,
};
