import 'dart:ui' show Rect;

import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:afaskin/data/models/enums.dart';

part 'analysis_result.freezed.dart';
part 'analysis_result.g.dart';

/// `POST /analyze` -> 200.
@freezed
abstract class AnalysisResult with _$AnalysisResult {
  const factory AnalysisResult({
    required String analysisId,
    required DateTime createdAt,
    required QualityReport quality,
    required SkinTypeResult skinType,
    required List<SkinCondition> conditions,
    required List<Roi> rois,
    required FusionInfo fusion,
    required String disclaimer,
  }) = _AnalysisResult;

  const AnalysisResult._();

  factory AnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$AnalysisResultFromJson(json);

  /// Conditions, highest probability first (the API does not guarantee order).
  List<SkinCondition> get conditionsByProbability =>
      [...conditions]..sort((a, b) => b.probability.compareTo(a.probability));

  SkinCondition? get topCondition {
    final sorted = conditionsByProbability;
    return sorted.isEmpty ? null : sorted.first;
  }
}

@freezed
abstract class QualityReport with _$QualityReport {
  const factory QualityReport({
    required bool passed,

    /// Variance of Laplacian.
    required double sharpness,

    /// Mean brightness, 0-255.
    required double brightness,
  }) = _QualityReport;

  factory QualityReport.fromJson(Map<String, dynamic> json) =>
      _$QualityReportFromJson(json);
}

@freezed
abstract class SkinTypeResult with _$SkinTypeResult {
  const factory SkinTypeResult({
    @JsonKey(unknownEnumValue: SkinType.unknown) required SkinType label,
    required double confidence,
    required Map<String, double> probs,
  }) = _SkinTypeResult;

  factory SkinTypeResult.fromJson(Map<String, dynamic> json) =>
      _$SkinTypeResultFromJson(json);
}

@freezed
abstract class SkinCondition with _$SkinCondition {
  const factory SkinCondition({
    @JsonKey(unknownEnumValue: SkinConditionLabel.unknown)
    required SkinConditionLabel label,
    required double probability,
    @JsonKey(unknownEnumValue: FaceRegion.unknown)
    required List<FaceRegion> regions,
    String? description,
  }) = _SkinCondition;

  factory SkinCondition.fromJson(Map<String, dynamic> json) =>
      _$SkinConditionFromJson(json);
}

/// A face region with its bounding box `[x, y, w, h]`, normalized 0-1
/// relative to the uploaded image.
@freezed
abstract class Roi with _$Roi {
  const factory Roi({
    @JsonKey(unknownEnumValue: FaceRegion.unknown) required FaceRegion name,
    required List<double> bbox,
  }) = _Roi;

  const Roi._();

  factory Roi.fromJson(Map<String, dynamic> json) => _$RoiFromJson(json);

  /// Normalized rect; scale by the image/widget size to draw.
  Rect get rect => bbox.length == 4
      ? Rect.fromLTWH(bbox[0], bbox[1], bbox[2], bbox[3])
      : Rect.zero;
}

@freezed
abstract class FusionInfo with _$FusionInfo {
  const factory FusionInfo({
    /// Weight of the image model: `P = a*P_model + (1-a)*P_questionnaire`.
    required double alpha,
  }) = _FusionInfo;

  factory FusionInfo.fromJson(Map<String, dynamic> json) =>
      _$FusionInfoFromJson(json);
}
