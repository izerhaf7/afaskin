// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AnalysisResult _$AnalysisResultFromJson(Map<String, dynamic> json) =>
    _AnalysisResult(
      analysisId: json['analysis_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      quality: QualityReport.fromJson(json['quality'] as Map<String, dynamic>),
      skinType: SkinTypeResult.fromJson(
        json['skin_type'] as Map<String, dynamic>,
      ),
      conditions: (json['conditions'] as List<dynamic>)
          .map((e) => SkinCondition.fromJson(e as Map<String, dynamic>))
          .toList(),
      rois: (json['rois'] as List<dynamic>)
          .map((e) => Roi.fromJson(e as Map<String, dynamic>))
          .toList(),
      fusion: FusionInfo.fromJson(json['fusion'] as Map<String, dynamic>),
      disclaimer: json['disclaimer'] as String,
    );

Map<String, dynamic> _$AnalysisResultToJson(_AnalysisResult instance) =>
    <String, dynamic>{
      'analysis_id': instance.analysisId,
      'created_at': instance.createdAt.toIso8601String(),
      'quality': instance.quality.toJson(),
      'skin_type': instance.skinType.toJson(),
      'conditions': instance.conditions.map((e) => e.toJson()).toList(),
      'rois': instance.rois.map((e) => e.toJson()).toList(),
      'fusion': instance.fusion.toJson(),
      'disclaimer': instance.disclaimer,
    };

_QualityReport _$QualityReportFromJson(Map<String, dynamic> json) =>
    _QualityReport(
      passed: json['passed'] as bool,
      sharpness: (json['sharpness'] as num).toDouble(),
      brightness: (json['brightness'] as num).toDouble(),
    );

Map<String, dynamic> _$QualityReportToJson(_QualityReport instance) =>
    <String, dynamic>{
      'passed': instance.passed,
      'sharpness': instance.sharpness,
      'brightness': instance.brightness,
    };

_SkinTypeResult _$SkinTypeResultFromJson(Map<String, dynamic> json) =>
    _SkinTypeResult(
      label: $enumDecode(
        _$SkinTypeEnumMap,
        json['label'],
        unknownValue: SkinType.unknown,
      ),
      confidence: (json['confidence'] as num).toDouble(),
      probs: (json['probs'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$SkinTypeResultToJson(_SkinTypeResult instance) =>
    <String, dynamic>{
      'label': _$SkinTypeEnumMap[instance.label]!,
      'confidence': instance.confidence,
      'probs': instance.probs,
    };

const _$SkinTypeEnumMap = {
  SkinType.oily: 'oily',
  SkinType.dry: 'dry',
  SkinType.normal: 'normal',
  SkinType.unknown: 'unknown',
};

_SkinCondition _$SkinConditionFromJson(Map<String, dynamic> json) =>
    _SkinCondition(
      label: $enumDecode(
        _$SkinConditionLabelEnumMap,
        json['label'],
        unknownValue: SkinConditionLabel.unknown,
      ),
      probability: (json['probability'] as num).toDouble(),
      regions: (json['regions'] as List<dynamic>)
          .map(
            (e) => $enumDecode(
              _$FaceRegionEnumMap,
              e,
              unknownValue: FaceRegion.unknown,
            ),
          )
          .toList(),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$SkinConditionToJson(_SkinCondition instance) =>
    <String, dynamic>{
      'label': _$SkinConditionLabelEnumMap[instance.label]!,
      'probability': instance.probability,
      'regions': instance.regions.map((e) => _$FaceRegionEnumMap[e]!).toList(),
      'description': instance.description,
    };

const _$SkinConditionLabelEnumMap = {
  SkinConditionLabel.acne: 'acne',
  SkinConditionLabel.birthmark: 'birthmark',
  SkinConditionLabel.blackhead: 'blackhead',
  SkinConditionLabel.cysts: 'cysts',
  SkinConditionLabel.milium: 'milium',
  SkinConditionLabel.papular: 'papular',
  SkinConditionLabel.purulent: 'purulent',
  SkinConditionLabel.scars: 'scars',
  SkinConditionLabel.whitehead: 'whitehead',
  SkinConditionLabel.unknown: 'unknown',
};

const _$FaceRegionEnumMap = {
  FaceRegion.forehead: 'forehead',
  FaceRegion.leftCheek: 'left_cheek',
  FaceRegion.rightCheek: 'right_cheek',
  FaceRegion.nose: 'nose',
  FaceRegion.chin: 'chin',
  FaceRegion.unknown: 'unknown',
};

_Roi _$RoiFromJson(Map<String, dynamic> json) => _Roi(
  name: $enumDecode(
    _$FaceRegionEnumMap,
    json['name'],
    unknownValue: FaceRegion.unknown,
  ),
  bbox: (json['bbox'] as List<dynamic>)
      .map((e) => (e as num).toDouble())
      .toList(),
);

Map<String, dynamic> _$RoiToJson(_Roi instance) => <String, dynamic>{
  'name': _$FaceRegionEnumMap[instance.name]!,
  'bbox': instance.bbox,
};

_FusionInfo _$FusionInfoFromJson(Map<String, dynamic> json) =>
    _FusionInfo(alpha: (json['alpha'] as num).toDouble());

Map<String, dynamic> _$FusionInfoToJson(_FusionInfo instance) =>
    <String, dynamic>{'alpha': instance.alpha};
