import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_status.freezed.dart';
part 'health_status.g.dart';

/// `GET /health`
@freezed
abstract class HealthStatus with _$HealthStatus {
  const factory HealthStatus({
    required String status,
    required String modelVersion,
  }) = _HealthStatus;

  const HealthStatus._();

  factory HealthStatus.fromJson(Map<String, dynamic> json) =>
      _$HealthStatusFromJson(json);

  bool get isOk => status == 'ok';
}
