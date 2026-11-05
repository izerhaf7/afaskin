// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HealthStatus _$HealthStatusFromJson(Map<String, dynamic> json) =>
    _HealthStatus(
      status: json['status'] as String,
      modelVersion: json['model_version'] as String,
    );

Map<String, dynamic> _$HealthStatusToJson(_HealthStatus instance) =>
    <String, dynamic>{
      'status': instance.status,
      'model_version': instance.modelVersion,
    };
