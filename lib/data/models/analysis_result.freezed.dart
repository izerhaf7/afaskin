// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analysis_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AnalysisResult {

 String get analysisId; DateTime get createdAt; QualityReport get quality; SkinTypeResult get skinType; List<SkinCondition> get conditions; List<Roi> get rois; FusionInfo get fusion; String get disclaimer;
/// Create a copy of AnalysisResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalysisResultCopyWith<AnalysisResult> get copyWith => _$AnalysisResultCopyWithImpl<AnalysisResult>(this as AnalysisResult, _$identity);

  /// Serializes this AnalysisResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AnalysisResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalysisResult&&(identical(other.analysisId, _this.analysisId) || other.analysisId == _this.analysisId)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.quality, _this.quality) || other.quality == _this.quality)&&(identical(other.skinType, _this.skinType) || other.skinType == _this.skinType)&&const DeepCollectionEquality().equals(other.conditions, _this.conditions)&&const DeepCollectionEquality().equals(other.rois, _this.rois)&&(identical(other.fusion, _this.fusion) || other.fusion == _this.fusion)&&(identical(other.disclaimer, _this.disclaimer) || other.disclaimer == _this.disclaimer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AnalysisResult;
  return Object.hash(runtimeType,_this.analysisId,_this.createdAt,_this.quality,_this.skinType,const DeepCollectionEquality().hash(_this.conditions),const DeepCollectionEquality().hash(_this.rois),_this.fusion,_this.disclaimer);
}

@override
String toString() {
  final _this = this as AnalysisResult;
  return 'AnalysisResult(analysisId: ${_this.analysisId}, createdAt: ${_this.createdAt}, quality: ${_this.quality}, skinType: ${_this.skinType}, conditions: ${_this.conditions}, rois: ${_this.rois}, fusion: ${_this.fusion}, disclaimer: ${_this.disclaimer})';
}


}

/// @nodoc
abstract mixin class $AnalysisResultCopyWith<$Res>  {
  factory $AnalysisResultCopyWith(AnalysisResult value, $Res Function(AnalysisResult) _then) = _$AnalysisResultCopyWithImpl;
@useResult
$Res call({
 String analysisId, DateTime createdAt, QualityReport quality, SkinTypeResult skinType, List<SkinCondition> conditions, List<Roi> rois, FusionInfo fusion, String disclaimer
});


$QualityReportCopyWith<$Res> get quality;$SkinTypeResultCopyWith<$Res> get skinType;$FusionInfoCopyWith<$Res> get fusion;

}
/// @nodoc
class _$AnalysisResultCopyWithImpl<$Res>
    implements $AnalysisResultCopyWith<$Res> {
  _$AnalysisResultCopyWithImpl(this._self, this._then);

  final AnalysisResult _self;
  final $Res Function(AnalysisResult) _then;

/// Create a copy of AnalysisResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? analysisId = null,Object? createdAt = null,Object? quality = null,Object? skinType = null,Object? conditions = null,Object? rois = null,Object? fusion = null,Object? disclaimer = null,}) {
  return _then(AnalysisResult(
analysisId: null == analysisId ? _self.analysisId : analysisId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,quality: null == quality ? _self.quality : quality // ignore: cast_nullable_to_non_nullable
as QualityReport,skinType: null == skinType ? _self.skinType : skinType // ignore: cast_nullable_to_non_nullable
as SkinTypeResult,conditions: null == conditions ? _self.conditions : conditions // ignore: cast_nullable_to_non_nullable
as List<SkinCondition>,rois: null == rois ? _self.rois : rois // ignore: cast_nullable_to_non_nullable
as List<Roi>,fusion: null == fusion ? _self.fusion : fusion // ignore: cast_nullable_to_non_nullable
as FusionInfo,disclaimer: null == disclaimer ? _self.disclaimer : disclaimer // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of AnalysisResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QualityReportCopyWith<$Res> get quality {
  
  return $QualityReportCopyWith<$Res>(_self.quality, (value) {
    return _then(_self.copyWith(quality: value));
  });
}/// Create a copy of AnalysisResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SkinTypeResultCopyWith<$Res> get skinType {
  
  return $SkinTypeResultCopyWith<$Res>(_self.skinType, (value) {
    return _then(_self.copyWith(skinType: value));
  });
}/// Create a copy of AnalysisResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FusionInfoCopyWith<$Res> get fusion {
  
  return $FusionInfoCopyWith<$Res>(_self.fusion, (value) {
    return _then(_self.copyWith(fusion: value));
  });
}
}


/// Adds pattern-matching-related methods to [AnalysisResult].
extension AnalysisResultPatterns on AnalysisResult {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalysisResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalysisResult() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalysisResult value)  $default,){
final _that = this;
switch (_that) {
case _AnalysisResult():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalysisResult value)?  $default,){
final _that = this;
switch (_that) {
case _AnalysisResult() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String analysisId,  DateTime createdAt,  QualityReport quality,  SkinTypeResult skinType,  List<SkinCondition> conditions,  List<Roi> rois,  FusionInfo fusion,  String disclaimer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalysisResult() when $default != null:
return $default(_that.analysisId,_that.createdAt,_that.quality,_that.skinType,_that.conditions,_that.rois,_that.fusion,_that.disclaimer);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String analysisId,  DateTime createdAt,  QualityReport quality,  SkinTypeResult skinType,  List<SkinCondition> conditions,  List<Roi> rois,  FusionInfo fusion,  String disclaimer)  $default,) {final _that = this;
switch (_that) {
case _AnalysisResult():
return $default(_that.analysisId,_that.createdAt,_that.quality,_that.skinType,_that.conditions,_that.rois,_that.fusion,_that.disclaimer);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String analysisId,  DateTime createdAt,  QualityReport quality,  SkinTypeResult skinType,  List<SkinCondition> conditions,  List<Roi> rois,  FusionInfo fusion,  String disclaimer)?  $default,) {final _that = this;
switch (_that) {
case _AnalysisResult() when $default != null:
return $default(_that.analysisId,_that.createdAt,_that.quality,_that.skinType,_that.conditions,_that.rois,_that.fusion,_that.disclaimer);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnalysisResult extends AnalysisResult {
  const _AnalysisResult({required this.analysisId, required this.createdAt, required this.quality, required this.skinType, required  List<SkinCondition> conditions, required  List<Roi> rois, required this.fusion, required this.disclaimer}): _conditions = conditions,_rois = rois,super._();
  factory _AnalysisResult.fromJson(Map<String, dynamic> json) => _$AnalysisResultFromJson(json);

@override final  String analysisId;
@override final  DateTime createdAt;
@override final  QualityReport quality;
@override final  SkinTypeResult skinType;
 final  List<SkinCondition> _conditions;
@override List<SkinCondition> get conditions {
  if (_conditions is EqualUnmodifiableListView) return _conditions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_conditions);
}

 final  List<Roi> _rois;
@override List<Roi> get rois {
  if (_rois is EqualUnmodifiableListView) return _rois;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rois);
}

@override final  FusionInfo fusion;
@override final  String disclaimer;

/// Create a copy of AnalysisResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalysisResultCopyWith<_AnalysisResult> get copyWith => __$AnalysisResultCopyWithImpl<_AnalysisResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalysisResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalysisResult&&(identical(other.analysisId, analysisId) || other.analysisId == analysisId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.quality, quality) || other.quality == quality)&&(identical(other.skinType, skinType) || other.skinType == skinType)&&const DeepCollectionEquality().equals(other.conditions, _conditions)&&const DeepCollectionEquality().equals(other.rois, _rois)&&(identical(other.fusion, fusion) || other.fusion == fusion)&&(identical(other.disclaimer, disclaimer) || other.disclaimer == disclaimer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,analysisId,createdAt,quality,skinType,const DeepCollectionEquality().hash(_conditions),const DeepCollectionEquality().hash(_rois),fusion,disclaimer);
}

@override
String toString() {
    return 'AnalysisResult(analysisId: $analysisId, createdAt: $createdAt, quality: $quality, skinType: $skinType, conditions: $conditions, rois: $rois, fusion: $fusion, disclaimer: $disclaimer)';
}


}

/// @nodoc
abstract mixin class _$AnalysisResultCopyWith<$Res> implements $AnalysisResultCopyWith<$Res> {
  factory _$AnalysisResultCopyWith(_AnalysisResult value, $Res Function(_AnalysisResult) _then) = __$AnalysisResultCopyWithImpl;
@override @useResult
$Res call({
 String analysisId, DateTime createdAt, QualityReport quality, SkinTypeResult skinType, List<SkinCondition> conditions, List<Roi> rois, FusionInfo fusion, String disclaimer
});


@override $QualityReportCopyWith<$Res> get quality;@override $SkinTypeResultCopyWith<$Res> get skinType;@override $FusionInfoCopyWith<$Res> get fusion;

}
/// @nodoc
class __$AnalysisResultCopyWithImpl<$Res>
    implements _$AnalysisResultCopyWith<$Res> {
  __$AnalysisResultCopyWithImpl(this._self, this._then);

  final _AnalysisResult _self;
  final $Res Function(_AnalysisResult) _then;

/// Create a copy of AnalysisResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? analysisId = null,Object? createdAt = null,Object? quality = null,Object? skinType = null,Object? conditions = null,Object? rois = null,Object? fusion = null,Object? disclaimer = null,}) {
  return _then(_AnalysisResult(
analysisId: null == analysisId ? _self.analysisId : analysisId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,quality: null == quality ? _self.quality : quality // ignore: cast_nullable_to_non_nullable
as QualityReport,skinType: null == skinType ? _self.skinType : skinType // ignore: cast_nullable_to_non_nullable
as SkinTypeResult,conditions: null == conditions ? _self._conditions : conditions // ignore: cast_nullable_to_non_nullable
as List<SkinCondition>,rois: null == rois ? _self._rois : rois // ignore: cast_nullable_to_non_nullable
as List<Roi>,fusion: null == fusion ? _self.fusion : fusion // ignore: cast_nullable_to_non_nullable
as FusionInfo,disclaimer: null == disclaimer ? _self.disclaimer : disclaimer // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of AnalysisResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QualityReportCopyWith<$Res> get quality {
  
  return $QualityReportCopyWith<$Res>(_self.quality, (value) {
    return _then(_self.copyWith(quality: value));
  });
}/// Create a copy of AnalysisResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SkinTypeResultCopyWith<$Res> get skinType {
  
  return $SkinTypeResultCopyWith<$Res>(_self.skinType, (value) {
    return _then(_self.copyWith(skinType: value));
  });
}/// Create a copy of AnalysisResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FusionInfoCopyWith<$Res> get fusion {
  
  return $FusionInfoCopyWith<$Res>(_self.fusion, (value) {
    return _then(_self.copyWith(fusion: value));
  });
}
}


/// @nodoc
mixin _$QualityReport {

 bool get passed;/// Variance of Laplacian.
 double get sharpness;/// Mean brightness, 0-255.
 double get brightness;
/// Create a copy of QualityReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QualityReportCopyWith<QualityReport> get copyWith => _$QualityReportCopyWithImpl<QualityReport>(this as QualityReport, _$identity);

  /// Serializes this QualityReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as QualityReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QualityReport&&(identical(other.passed, _this.passed) || other.passed == _this.passed)&&(identical(other.sharpness, _this.sharpness) || other.sharpness == _this.sharpness)&&(identical(other.brightness, _this.brightness) || other.brightness == _this.brightness));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as QualityReport;
  return Object.hash(runtimeType,_this.passed,_this.sharpness,_this.brightness);
}

@override
String toString() {
  final _this = this as QualityReport;
  return 'QualityReport(passed: ${_this.passed}, sharpness: ${_this.sharpness}, brightness: ${_this.brightness})';
}


}

/// @nodoc
abstract mixin class $QualityReportCopyWith<$Res>  {
  factory $QualityReportCopyWith(QualityReport value, $Res Function(QualityReport) _then) = _$QualityReportCopyWithImpl;
@useResult
$Res call({
 bool passed, double sharpness, double brightness
});




}
/// @nodoc
class _$QualityReportCopyWithImpl<$Res>
    implements $QualityReportCopyWith<$Res> {
  _$QualityReportCopyWithImpl(this._self, this._then);

  final QualityReport _self;
  final $Res Function(QualityReport) _then;

/// Create a copy of QualityReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? passed = null,Object? sharpness = null,Object? brightness = null,}) {
  return _then(QualityReport(
passed: null == passed ? _self.passed : passed // ignore: cast_nullable_to_non_nullable
as bool,sharpness: null == sharpness ? _self.sharpness : sharpness // ignore: cast_nullable_to_non_nullable
as double,brightness: null == brightness ? _self.brightness : brightness // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [QualityReport].
extension QualityReportPatterns on QualityReport {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QualityReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QualityReport() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QualityReport value)  $default,){
final _that = this;
switch (_that) {
case _QualityReport():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QualityReport value)?  $default,){
final _that = this;
switch (_that) {
case _QualityReport() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool passed,  double sharpness,  double brightness)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QualityReport() when $default != null:
return $default(_that.passed,_that.sharpness,_that.brightness);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool passed,  double sharpness,  double brightness)  $default,) {final _that = this;
switch (_that) {
case _QualityReport():
return $default(_that.passed,_that.sharpness,_that.brightness);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool passed,  double sharpness,  double brightness)?  $default,) {final _that = this;
switch (_that) {
case _QualityReport() when $default != null:
return $default(_that.passed,_that.sharpness,_that.brightness);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QualityReport implements QualityReport {
  const _QualityReport({required this.passed, required this.sharpness, required this.brightness});
  factory _QualityReport.fromJson(Map<String, dynamic> json) => _$QualityReportFromJson(json);

@override final  bool passed;
/// Variance of Laplacian.
@override final  double sharpness;
/// Mean brightness, 0-255.
@override final  double brightness;

/// Create a copy of QualityReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QualityReportCopyWith<_QualityReport> get copyWith => __$QualityReportCopyWithImpl<_QualityReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QualityReportToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _QualityReport&&(identical(other.passed, passed) || other.passed == passed)&&(identical(other.sharpness, sharpness) || other.sharpness == sharpness)&&(identical(other.brightness, brightness) || other.brightness == brightness));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,passed,sharpness,brightness);
}

@override
String toString() {
    return 'QualityReport(passed: $passed, sharpness: $sharpness, brightness: $brightness)';
}


}

/// @nodoc
abstract mixin class _$QualityReportCopyWith<$Res> implements $QualityReportCopyWith<$Res> {
  factory _$QualityReportCopyWith(_QualityReport value, $Res Function(_QualityReport) _then) = __$QualityReportCopyWithImpl;
@override @useResult
$Res call({
 bool passed, double sharpness, double brightness
});




}
/// @nodoc
class __$QualityReportCopyWithImpl<$Res>
    implements _$QualityReportCopyWith<$Res> {
  __$QualityReportCopyWithImpl(this._self, this._then);

  final _QualityReport _self;
  final $Res Function(_QualityReport) _then;

/// Create a copy of QualityReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? passed = null,Object? sharpness = null,Object? brightness = null,}) {
  return _then(_QualityReport(
passed: null == passed ? _self.passed : passed // ignore: cast_nullable_to_non_nullable
as bool,sharpness: null == sharpness ? _self.sharpness : sharpness // ignore: cast_nullable_to_non_nullable
as double,brightness: null == brightness ? _self.brightness : brightness // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$SkinTypeResult {

@JsonKey(unknownEnumValue: SkinType.unknown) SkinType get label; double get confidence; Map<String, double> get probs;
/// Create a copy of SkinTypeResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SkinTypeResultCopyWith<SkinTypeResult> get copyWith => _$SkinTypeResultCopyWithImpl<SkinTypeResult>(this as SkinTypeResult, _$identity);

  /// Serializes this SkinTypeResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SkinTypeResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SkinTypeResult&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.confidence, _this.confidence) || other.confidence == _this.confidence)&&const DeepCollectionEquality().equals(other.probs, _this.probs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SkinTypeResult;
  return Object.hash(runtimeType,_this.label,_this.confidence,const DeepCollectionEquality().hash(_this.probs));
}

@override
String toString() {
  final _this = this as SkinTypeResult;
  return 'SkinTypeResult(label: ${_this.label}, confidence: ${_this.confidence}, probs: ${_this.probs})';
}


}

/// @nodoc
abstract mixin class $SkinTypeResultCopyWith<$Res>  {
  factory $SkinTypeResultCopyWith(SkinTypeResult value, $Res Function(SkinTypeResult) _then) = _$SkinTypeResultCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: SkinType.unknown) SkinType label, double confidence, Map<String, double> probs
});




}
/// @nodoc
class _$SkinTypeResultCopyWithImpl<$Res>
    implements $SkinTypeResultCopyWith<$Res> {
  _$SkinTypeResultCopyWithImpl(this._self, this._then);

  final SkinTypeResult _self;
  final $Res Function(SkinTypeResult) _then;

/// Create a copy of SkinTypeResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? confidence = null,Object? probs = null,}) {
  return _then(SkinTypeResult(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as SkinType,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,probs: null == probs ? _self.probs : probs // ignore: cast_nullable_to_non_nullable
as Map<String, double>,
  ));
}

}


/// Adds pattern-matching-related methods to [SkinTypeResult].
extension SkinTypeResultPatterns on SkinTypeResult {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SkinTypeResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SkinTypeResult() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SkinTypeResult value)  $default,){
final _that = this;
switch (_that) {
case _SkinTypeResult():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SkinTypeResult value)?  $default,){
final _that = this;
switch (_that) {
case _SkinTypeResult() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: SkinType.unknown)  SkinType label,  double confidence,  Map<String, double> probs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SkinTypeResult() when $default != null:
return $default(_that.label,_that.confidence,_that.probs);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: SkinType.unknown)  SkinType label,  double confidence,  Map<String, double> probs)  $default,) {final _that = this;
switch (_that) {
case _SkinTypeResult():
return $default(_that.label,_that.confidence,_that.probs);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: SkinType.unknown)  SkinType label,  double confidence,  Map<String, double> probs)?  $default,) {final _that = this;
switch (_that) {
case _SkinTypeResult() when $default != null:
return $default(_that.label,_that.confidence,_that.probs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SkinTypeResult implements SkinTypeResult {
  const _SkinTypeResult({@JsonKey(unknownEnumValue: SkinType.unknown) required this.label, required this.confidence, required  Map<String, double> probs}): _probs = probs;
  factory _SkinTypeResult.fromJson(Map<String, dynamic> json) => _$SkinTypeResultFromJson(json);

@override@JsonKey(unknownEnumValue: SkinType.unknown) final  SkinType label;
@override final  double confidence;
 final  Map<String, double> _probs;
@override Map<String, double> get probs {
  if (_probs is EqualUnmodifiableMapView) return _probs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_probs);
}


/// Create a copy of SkinTypeResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SkinTypeResultCopyWith<_SkinTypeResult> get copyWith => __$SkinTypeResultCopyWithImpl<_SkinTypeResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SkinTypeResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SkinTypeResult&&(identical(other.label, label) || other.label == label)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&const DeepCollectionEquality().equals(other.probs, _probs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,label,confidence,const DeepCollectionEquality().hash(_probs));
}

@override
String toString() {
    return 'SkinTypeResult(label: $label, confidence: $confidence, probs: $probs)';
}


}

/// @nodoc
abstract mixin class _$SkinTypeResultCopyWith<$Res> implements $SkinTypeResultCopyWith<$Res> {
  factory _$SkinTypeResultCopyWith(_SkinTypeResult value, $Res Function(_SkinTypeResult) _then) = __$SkinTypeResultCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: SkinType.unknown) SkinType label, double confidence, Map<String, double> probs
});




}
/// @nodoc
class __$SkinTypeResultCopyWithImpl<$Res>
    implements _$SkinTypeResultCopyWith<$Res> {
  __$SkinTypeResultCopyWithImpl(this._self, this._then);

  final _SkinTypeResult _self;
  final $Res Function(_SkinTypeResult) _then;

/// Create a copy of SkinTypeResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? confidence = null,Object? probs = null,}) {
  return _then(_SkinTypeResult(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as SkinType,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,probs: null == probs ? _self._probs : probs // ignore: cast_nullable_to_non_nullable
as Map<String, double>,
  ));
}


}


/// @nodoc
mixin _$SkinCondition {

@JsonKey(unknownEnumValue: SkinConditionLabel.unknown) SkinConditionLabel get label; double get probability;@JsonKey(unknownEnumValue: FaceRegion.unknown) List<FaceRegion> get regions; String? get description;
/// Create a copy of SkinCondition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SkinConditionCopyWith<SkinCondition> get copyWith => _$SkinConditionCopyWithImpl<SkinCondition>(this as SkinCondition, _$identity);

  /// Serializes this SkinCondition to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SkinCondition;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SkinCondition&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.probability, _this.probability) || other.probability == _this.probability)&&const DeepCollectionEquality().equals(other.regions, _this.regions)&&(identical(other.description, _this.description) || other.description == _this.description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SkinCondition;
  return Object.hash(runtimeType,_this.label,_this.probability,const DeepCollectionEquality().hash(_this.regions),_this.description);
}

@override
String toString() {
  final _this = this as SkinCondition;
  return 'SkinCondition(label: ${_this.label}, probability: ${_this.probability}, regions: ${_this.regions}, description: ${_this.description})';
}


}

/// @nodoc
abstract mixin class $SkinConditionCopyWith<$Res>  {
  factory $SkinConditionCopyWith(SkinCondition value, $Res Function(SkinCondition) _then) = _$SkinConditionCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: SkinConditionLabel.unknown) SkinConditionLabel label, double probability,@JsonKey(unknownEnumValue: FaceRegion.unknown) List<FaceRegion> regions, String? description
});




}
/// @nodoc
class _$SkinConditionCopyWithImpl<$Res>
    implements $SkinConditionCopyWith<$Res> {
  _$SkinConditionCopyWithImpl(this._self, this._then);

  final SkinCondition _self;
  final $Res Function(SkinCondition) _then;

/// Create a copy of SkinCondition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? probability = null,Object? regions = null,Object? description = freezed,}) {
  return _then(SkinCondition(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as SkinConditionLabel,probability: null == probability ? _self.probability : probability // ignore: cast_nullable_to_non_nullable
as double,regions: null == regions ? _self.regions : regions // ignore: cast_nullable_to_non_nullable
as List<FaceRegion>,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SkinCondition].
extension SkinConditionPatterns on SkinCondition {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SkinCondition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SkinCondition() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SkinCondition value)  $default,){
final _that = this;
switch (_that) {
case _SkinCondition():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SkinCondition value)?  $default,){
final _that = this;
switch (_that) {
case _SkinCondition() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: SkinConditionLabel.unknown)  SkinConditionLabel label,  double probability, @JsonKey(unknownEnumValue: FaceRegion.unknown)  List<FaceRegion> regions,  String? description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SkinCondition() when $default != null:
return $default(_that.label,_that.probability,_that.regions,_that.description);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: SkinConditionLabel.unknown)  SkinConditionLabel label,  double probability, @JsonKey(unknownEnumValue: FaceRegion.unknown)  List<FaceRegion> regions,  String? description)  $default,) {final _that = this;
switch (_that) {
case _SkinCondition():
return $default(_that.label,_that.probability,_that.regions,_that.description);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: SkinConditionLabel.unknown)  SkinConditionLabel label,  double probability, @JsonKey(unknownEnumValue: FaceRegion.unknown)  List<FaceRegion> regions,  String? description)?  $default,) {final _that = this;
switch (_that) {
case _SkinCondition() when $default != null:
return $default(_that.label,_that.probability,_that.regions,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SkinCondition implements SkinCondition {
  const _SkinCondition({@JsonKey(unknownEnumValue: SkinConditionLabel.unknown) required this.label, required this.probability, @JsonKey(unknownEnumValue: FaceRegion.unknown) required  List<FaceRegion> regions, this.description}): _regions = regions;
  factory _SkinCondition.fromJson(Map<String, dynamic> json) => _$SkinConditionFromJson(json);

@override@JsonKey(unknownEnumValue: SkinConditionLabel.unknown) final  SkinConditionLabel label;
@override final  double probability;
 final  List<FaceRegion> _regions;
@override@JsonKey(unknownEnumValue: FaceRegion.unknown) List<FaceRegion> get regions {
  if (_regions is EqualUnmodifiableListView) return _regions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_regions);
}

@override final  String? description;

/// Create a copy of SkinCondition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SkinConditionCopyWith<_SkinCondition> get copyWith => __$SkinConditionCopyWithImpl<_SkinCondition>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SkinConditionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SkinCondition&&(identical(other.label, label) || other.label == label)&&(identical(other.probability, probability) || other.probability == probability)&&const DeepCollectionEquality().equals(other.regions, _regions)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,label,probability,const DeepCollectionEquality().hash(_regions),description);
}

@override
String toString() {
    return 'SkinCondition(label: $label, probability: $probability, regions: $regions, description: $description)';
}


}

/// @nodoc
abstract mixin class _$SkinConditionCopyWith<$Res> implements $SkinConditionCopyWith<$Res> {
  factory _$SkinConditionCopyWith(_SkinCondition value, $Res Function(_SkinCondition) _then) = __$SkinConditionCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: SkinConditionLabel.unknown) SkinConditionLabel label, double probability,@JsonKey(unknownEnumValue: FaceRegion.unknown) List<FaceRegion> regions, String? description
});




}
/// @nodoc
class __$SkinConditionCopyWithImpl<$Res>
    implements _$SkinConditionCopyWith<$Res> {
  __$SkinConditionCopyWithImpl(this._self, this._then);

  final _SkinCondition _self;
  final $Res Function(_SkinCondition) _then;

/// Create a copy of SkinCondition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? probability = null,Object? regions = null,Object? description = freezed,}) {
  return _then(_SkinCondition(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as SkinConditionLabel,probability: null == probability ? _self.probability : probability // ignore: cast_nullable_to_non_nullable
as double,regions: null == regions ? _self._regions : regions // ignore: cast_nullable_to_non_nullable
as List<FaceRegion>,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Roi {

@JsonKey(unknownEnumValue: FaceRegion.unknown) FaceRegion get name; List<double> get bbox;
/// Create a copy of Roi
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoiCopyWith<Roi> get copyWith => _$RoiCopyWithImpl<Roi>(this as Roi, _$identity);

  /// Serializes this Roi to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Roi;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Roi&&(identical(other.name, _this.name) || other.name == _this.name)&&const DeepCollectionEquality().equals(other.bbox, _this.bbox));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Roi;
  return Object.hash(runtimeType,_this.name,const DeepCollectionEquality().hash(_this.bbox));
}

@override
String toString() {
  final _this = this as Roi;
  return 'Roi(name: ${_this.name}, bbox: ${_this.bbox})';
}


}

/// @nodoc
abstract mixin class $RoiCopyWith<$Res>  {
  factory $RoiCopyWith(Roi value, $Res Function(Roi) _then) = _$RoiCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: FaceRegion.unknown) FaceRegion name, List<double> bbox
});




}
/// @nodoc
class _$RoiCopyWithImpl<$Res>
    implements $RoiCopyWith<$Res> {
  _$RoiCopyWithImpl(this._self, this._then);

  final Roi _self;
  final $Res Function(Roi) _then;

/// Create a copy of Roi
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? bbox = null,}) {
  return _then(Roi(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as FaceRegion,bbox: null == bbox ? _self.bbox : bbox // ignore: cast_nullable_to_non_nullable
as List<double>,
  ));
}

}


/// Adds pattern-matching-related methods to [Roi].
extension RoiPatterns on Roi {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Roi value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Roi() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Roi value)  $default,){
final _that = this;
switch (_that) {
case _Roi():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Roi value)?  $default,){
final _that = this;
switch (_that) {
case _Roi() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: FaceRegion.unknown)  FaceRegion name,  List<double> bbox)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Roi() when $default != null:
return $default(_that.name,_that.bbox);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: FaceRegion.unknown)  FaceRegion name,  List<double> bbox)  $default,) {final _that = this;
switch (_that) {
case _Roi():
return $default(_that.name,_that.bbox);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: FaceRegion.unknown)  FaceRegion name,  List<double> bbox)?  $default,) {final _that = this;
switch (_that) {
case _Roi() when $default != null:
return $default(_that.name,_that.bbox);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Roi extends Roi {
  const _Roi({@JsonKey(unknownEnumValue: FaceRegion.unknown) required this.name, required  List<double> bbox}): _bbox = bbox,super._();
  factory _Roi.fromJson(Map<String, dynamic> json) => _$RoiFromJson(json);

@override@JsonKey(unknownEnumValue: FaceRegion.unknown) final  FaceRegion name;
 final  List<double> _bbox;
@override List<double> get bbox {
  if (_bbox is EqualUnmodifiableListView) return _bbox;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bbox);
}


/// Create a copy of Roi
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoiCopyWith<_Roi> get copyWith => __$RoiCopyWithImpl<_Roi>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoiToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Roi&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.bbox, _bbox));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,const DeepCollectionEquality().hash(_bbox));
}

@override
String toString() {
    return 'Roi(name: $name, bbox: $bbox)';
}


}

/// @nodoc
abstract mixin class _$RoiCopyWith<$Res> implements $RoiCopyWith<$Res> {
  factory _$RoiCopyWith(_Roi value, $Res Function(_Roi) _then) = __$RoiCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: FaceRegion.unknown) FaceRegion name, List<double> bbox
});




}
/// @nodoc
class __$RoiCopyWithImpl<$Res>
    implements _$RoiCopyWith<$Res> {
  __$RoiCopyWithImpl(this._self, this._then);

  final _Roi _self;
  final $Res Function(_Roi) _then;

/// Create a copy of Roi
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? bbox = null,}) {
  return _then(_Roi(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as FaceRegion,bbox: null == bbox ? _self._bbox : bbox // ignore: cast_nullable_to_non_nullable
as List<double>,
  ));
}


}


/// @nodoc
mixin _$FusionInfo {

/// Weight of the image model: `P = a*P_model + (1-a)*P_questionnaire`.
 double get alpha;
/// Create a copy of FusionInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FusionInfoCopyWith<FusionInfo> get copyWith => _$FusionInfoCopyWithImpl<FusionInfo>(this as FusionInfo, _$identity);

  /// Serializes this FusionInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FusionInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FusionInfo&&(identical(other.alpha, _this.alpha) || other.alpha == _this.alpha));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FusionInfo;
  return Object.hash(runtimeType,_this.alpha);
}

@override
String toString() {
  final _this = this as FusionInfo;
  return 'FusionInfo(alpha: ${_this.alpha})';
}


}

/// @nodoc
abstract mixin class $FusionInfoCopyWith<$Res>  {
  factory $FusionInfoCopyWith(FusionInfo value, $Res Function(FusionInfo) _then) = _$FusionInfoCopyWithImpl;
@useResult
$Res call({
 double alpha
});




}
/// @nodoc
class _$FusionInfoCopyWithImpl<$Res>
    implements $FusionInfoCopyWith<$Res> {
  _$FusionInfoCopyWithImpl(this._self, this._then);

  final FusionInfo _self;
  final $Res Function(FusionInfo) _then;

/// Create a copy of FusionInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? alpha = null,}) {
  return _then(FusionInfo(
alpha: null == alpha ? _self.alpha : alpha // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [FusionInfo].
extension FusionInfoPatterns on FusionInfo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FusionInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FusionInfo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FusionInfo value)  $default,){
final _that = this;
switch (_that) {
case _FusionInfo():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FusionInfo value)?  $default,){
final _that = this;
switch (_that) {
case _FusionInfo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double alpha)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FusionInfo() when $default != null:
return $default(_that.alpha);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double alpha)  $default,) {final _that = this;
switch (_that) {
case _FusionInfo():
return $default(_that.alpha);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double alpha)?  $default,) {final _that = this;
switch (_that) {
case _FusionInfo() when $default != null:
return $default(_that.alpha);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FusionInfo implements FusionInfo {
  const _FusionInfo({required this.alpha});
  factory _FusionInfo.fromJson(Map<String, dynamic> json) => _$FusionInfoFromJson(json);

/// Weight of the image model: `P = a*P_model + (1-a)*P_questionnaire`.
@override final  double alpha;

/// Create a copy of FusionInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FusionInfoCopyWith<_FusionInfo> get copyWith => __$FusionInfoCopyWithImpl<_FusionInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FusionInfoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FusionInfo&&(identical(other.alpha, alpha) || other.alpha == alpha));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,alpha);
}

@override
String toString() {
    return 'FusionInfo(alpha: $alpha)';
}


}

/// @nodoc
abstract mixin class _$FusionInfoCopyWith<$Res> implements $FusionInfoCopyWith<$Res> {
  factory _$FusionInfoCopyWith(_FusionInfo value, $Res Function(_FusionInfo) _then) = __$FusionInfoCopyWithImpl;
@override @useResult
$Res call({
 double alpha
});




}
/// @nodoc
class __$FusionInfoCopyWithImpl<$Res>
    implements _$FusionInfoCopyWith<$Res> {
  __$FusionInfoCopyWithImpl(this._self, this._then);

  final _FusionInfo _self;
  final $Res Function(_FusionInfo) _then;

/// Create a copy of FusionInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? alpha = null,}) {
  return _then(_FusionInfo(
alpha: null == alpha ? _self.alpha : alpha // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
