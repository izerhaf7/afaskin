import 'package:freezed_annotation/freezed_annotation.dart';

part 'quality_rejection.freezed.dart';
part 'quality_rejection.g.dart';

/// `POST /analyze` -> 422 body when the quality gate fails.
@freezed
abstract class QualityRejectionBody with _$QualityRejectionBody {
  const factory QualityRejectionBody({
    required String error,
    @Default(<String>[]) List<String> reasons,
    String? message,
  }) = _QualityRejectionBody;

  factory QualityRejectionBody.fromJson(Map<String, dynamic> json) =>
      _$QualityRejectionBodyFromJson(json);

  static const String code = 'quality_rejected';
}
