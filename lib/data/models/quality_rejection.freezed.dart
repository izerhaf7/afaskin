// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quality_rejection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QualityRejectionBody {

 String get error; List<String> get reasons; String? get message;
/// Create a copy of QualityRejectionBody
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QualityRejectionBodyCopyWith<QualityRejectionBody> get copyWith => _$QualityRejectionBodyCopyWithImpl<QualityRejectionBody>(this as QualityRejectionBody, _$identity);

  /// Serializes this QualityRejectionBody to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as QualityRejectionBody;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QualityRejectionBody&&(identical(other.error, _this.error) || other.error == _this.error)&&const DeepCollectionEquality().equals(other.reasons, _this.reasons)&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as QualityRejectionBody;
  return Object.hash(runtimeType,_this.error,const DeepCollectionEquality().hash(_this.reasons),_this.message);
}

@override
String toString() {
  final _this = this as QualityRejectionBody;
  return 'QualityRejectionBody(error: ${_this.error}, reasons: ${_this.reasons}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $QualityRejectionBodyCopyWith<$Res>  {
  factory $QualityRejectionBodyCopyWith(QualityRejectionBody value, $Res Function(QualityRejectionBody) _then) = _$QualityRejectionBodyCopyWithImpl;
@useResult
$Res call({
 String error, List<String> reasons, String? message
});




}
/// @nodoc
class _$QualityRejectionBodyCopyWithImpl<$Res>
    implements $QualityRejectionBodyCopyWith<$Res> {
  _$QualityRejectionBodyCopyWithImpl(this._self, this._then);

  final QualityRejectionBody _self;
  final $Res Function(QualityRejectionBody) _then;

/// Create a copy of QualityRejectionBody
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? error = null,Object? reasons = null,Object? message = freezed,}) {
  return _then(QualityRejectionBody(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,reasons: null == reasons ? _self.reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<String>,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [QualityRejectionBody].
extension QualityRejectionBodyPatterns on QualityRejectionBody {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QualityRejectionBody value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QualityRejectionBody() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QualityRejectionBody value)  $default,){
final _that = this;
switch (_that) {
case _QualityRejectionBody():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QualityRejectionBody value)?  $default,){
final _that = this;
switch (_that) {
case _QualityRejectionBody() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String error,  List<String> reasons,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QualityRejectionBody() when $default != null:
return $default(_that.error,_that.reasons,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String error,  List<String> reasons,  String? message)  $default,) {final _that = this;
switch (_that) {
case _QualityRejectionBody():
return $default(_that.error,_that.reasons,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String error,  List<String> reasons,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _QualityRejectionBody() when $default != null:
return $default(_that.error,_that.reasons,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QualityRejectionBody implements QualityRejectionBody {
  const _QualityRejectionBody({required this.error,  List<String> reasons = const <String>[], this.message}): _reasons = reasons;
  factory _QualityRejectionBody.fromJson(Map<String, dynamic> json) => _$QualityRejectionBodyFromJson(json);

@override final  String error;
 final  List<String> _reasons;
@override@JsonKey() List<String> get reasons {
  if (_reasons is EqualUnmodifiableListView) return _reasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reasons);
}

@override final  String? message;

/// Create a copy of QualityRejectionBody
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QualityRejectionBodyCopyWith<_QualityRejectionBody> get copyWith => __$QualityRejectionBodyCopyWithImpl<_QualityRejectionBody>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QualityRejectionBodyToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _QualityRejectionBody&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other.reasons, _reasons)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,error,const DeepCollectionEquality().hash(_reasons),message);
}

@override
String toString() {
    return 'QualityRejectionBody(error: $error, reasons: $reasons, message: $message)';
}


}

/// @nodoc
abstract mixin class _$QualityRejectionBodyCopyWith<$Res> implements $QualityRejectionBodyCopyWith<$Res> {
  factory _$QualityRejectionBodyCopyWith(_QualityRejectionBody value, $Res Function(_QualityRejectionBody) _then) = __$QualityRejectionBodyCopyWithImpl;
@override @useResult
$Res call({
 String error, List<String> reasons, String? message
});




}
/// @nodoc
class __$QualityRejectionBodyCopyWithImpl<$Res>
    implements _$QualityRejectionBodyCopyWith<$Res> {
  __$QualityRejectionBodyCopyWithImpl(this._self, this._then);

  final _QualityRejectionBody _self;
  final $Res Function(_QualityRejectionBody) _then;

/// Create a copy of QualityRejectionBody
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? error = null,Object? reasons = null,Object? message = freezed,}) {
  return _then(_QualityRejectionBody(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,reasons: null == reasons ? _self._reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<String>,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
