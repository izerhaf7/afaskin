// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'questionnaire.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Questionnaire {

 String get version; List<Question> get questions;
/// Create a copy of Questionnaire
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuestionnaireCopyWith<Questionnaire> get copyWith => _$QuestionnaireCopyWithImpl<Questionnaire>(this as Questionnaire, _$identity);

  /// Serializes this Questionnaire to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Questionnaire;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Questionnaire&&(identical(other.version, _this.version) || other.version == _this.version)&&const DeepCollectionEquality().equals(other.questions, _this.questions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Questionnaire;
  return Object.hash(runtimeType,_this.version,const DeepCollectionEquality().hash(_this.questions));
}

@override
String toString() {
  final _this = this as Questionnaire;
  return 'Questionnaire(version: ${_this.version}, questions: ${_this.questions})';
}


}

/// @nodoc
abstract mixin class $QuestionnaireCopyWith<$Res>  {
  factory $QuestionnaireCopyWith(Questionnaire value, $Res Function(Questionnaire) _then) = _$QuestionnaireCopyWithImpl;
@useResult
$Res call({
 String version, List<Question> questions
});




}
/// @nodoc
class _$QuestionnaireCopyWithImpl<$Res>
    implements $QuestionnaireCopyWith<$Res> {
  _$QuestionnaireCopyWithImpl(this._self, this._then);

  final Questionnaire _self;
  final $Res Function(Questionnaire) _then;

/// Create a copy of Questionnaire
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? questions = null,}) {
  return _then(Questionnaire(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,questions: null == questions ? _self.questions : questions // ignore: cast_nullable_to_non_nullable
as List<Question>,
  ));
}

}


/// Adds pattern-matching-related methods to [Questionnaire].
extension QuestionnairePatterns on Questionnaire {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Questionnaire value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Questionnaire() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Questionnaire value)  $default,){
final _that = this;
switch (_that) {
case _Questionnaire():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Questionnaire value)?  $default,){
final _that = this;
switch (_that) {
case _Questionnaire() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String version,  List<Question> questions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Questionnaire() when $default != null:
return $default(_that.version,_that.questions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String version,  List<Question> questions)  $default,) {final _that = this;
switch (_that) {
case _Questionnaire():
return $default(_that.version,_that.questions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String version,  List<Question> questions)?  $default,) {final _that = this;
switch (_that) {
case _Questionnaire() when $default != null:
return $default(_that.version,_that.questions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Questionnaire implements Questionnaire {
  const _Questionnaire({required this.version, required  List<Question> questions}): _questions = questions;
  factory _Questionnaire.fromJson(Map<String, dynamic> json) => _$QuestionnaireFromJson(json);

@override final  String version;
 final  List<Question> _questions;
@override List<Question> get questions {
  if (_questions is EqualUnmodifiableListView) return _questions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_questions);
}


/// Create a copy of Questionnaire
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuestionnaireCopyWith<_Questionnaire> get copyWith => __$QuestionnaireCopyWithImpl<_Questionnaire>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuestionnaireToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Questionnaire&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other.questions, _questions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,version,const DeepCollectionEquality().hash(_questions));
}

@override
String toString() {
    return 'Questionnaire(version: $version, questions: $questions)';
}


}

/// @nodoc
abstract mixin class _$QuestionnaireCopyWith<$Res> implements $QuestionnaireCopyWith<$Res> {
  factory _$QuestionnaireCopyWith(_Questionnaire value, $Res Function(_Questionnaire) _then) = __$QuestionnaireCopyWithImpl;
@override @useResult
$Res call({
 String version, List<Question> questions
});




}
/// @nodoc
class __$QuestionnaireCopyWithImpl<$Res>
    implements _$QuestionnaireCopyWith<$Res> {
  __$QuestionnaireCopyWithImpl(this._self, this._then);

  final _Questionnaire _self;
  final $Res Function(_Questionnaire) _then;

/// Create a copy of Questionnaire
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? questions = null,}) {
  return _then(_Questionnaire(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,questions: null == questions ? _self._questions : questions // ignore: cast_nullable_to_non_nullable
as List<Question>,
  ));
}


}


/// @nodoc
mixin _$Question {

 String get id; String get text; LikertScale get scale;
/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuestionCopyWith<Question> get copyWith => _$QuestionCopyWithImpl<Question>(this as Question, _$identity);

  /// Serializes this Question to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Question;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Question&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.scale, _this.scale) || other.scale == _this.scale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Question;
  return Object.hash(runtimeType,_this.id,_this.text,_this.scale);
}

@override
String toString() {
  final _this = this as Question;
  return 'Question(id: ${_this.id}, text: ${_this.text}, scale: ${_this.scale})';
}


}

/// @nodoc
abstract mixin class $QuestionCopyWith<$Res>  {
  factory $QuestionCopyWith(Question value, $Res Function(Question) _then) = _$QuestionCopyWithImpl;
@useResult
$Res call({
 String id, String text, LikertScale scale
});


$LikertScaleCopyWith<$Res> get scale;

}
/// @nodoc
class _$QuestionCopyWithImpl<$Res>
    implements $QuestionCopyWith<$Res> {
  _$QuestionCopyWithImpl(this._self, this._then);

  final Question _self;
  final $Res Function(Question) _then;

/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? text = null,Object? scale = null,}) {
  return _then(Question(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as LikertScale,
  ));
}
/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LikertScaleCopyWith<$Res> get scale {
  
  return $LikertScaleCopyWith<$Res>(_self.scale, (value) {
    return _then(_self.copyWith(scale: value));
  });
}
}


/// Adds pattern-matching-related methods to [Question].
extension QuestionPatterns on Question {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Question value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Question() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Question value)  $default,){
final _that = this;
switch (_that) {
case _Question():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Question value)?  $default,){
final _that = this;
switch (_that) {
case _Question() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String text,  LikertScale scale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Question() when $default != null:
return $default(_that.id,_that.text,_that.scale);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String text,  LikertScale scale)  $default,) {final _that = this;
switch (_that) {
case _Question():
return $default(_that.id,_that.text,_that.scale);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String text,  LikertScale scale)?  $default,) {final _that = this;
switch (_that) {
case _Question() when $default != null:
return $default(_that.id,_that.text,_that.scale);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Question implements Question {
  const _Question({required this.id, required this.text, required this.scale});
  factory _Question.fromJson(Map<String, dynamic> json) => _$QuestionFromJson(json);

@override final  String id;
@override final  String text;
@override final  LikertScale scale;

/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuestionCopyWith<_Question> get copyWith => __$QuestionCopyWithImpl<_Question>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuestionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Question&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.scale, scale) || other.scale == scale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,text,scale);
}

@override
String toString() {
    return 'Question(id: $id, text: $text, scale: $scale)';
}


}

/// @nodoc
abstract mixin class _$QuestionCopyWith<$Res> implements $QuestionCopyWith<$Res> {
  factory _$QuestionCopyWith(_Question value, $Res Function(_Question) _then) = __$QuestionCopyWithImpl;
@override @useResult
$Res call({
 String id, String text, LikertScale scale
});


@override $LikertScaleCopyWith<$Res> get scale;

}
/// @nodoc
class __$QuestionCopyWithImpl<$Res>
    implements _$QuestionCopyWith<$Res> {
  __$QuestionCopyWithImpl(this._self, this._then);

  final _Question _self;
  final $Res Function(_Question) _then;

/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? text = null,Object? scale = null,}) {
  return _then(_Question(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as LikertScale,
  ));
}

/// Create a copy of Question
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LikertScaleCopyWith<$Res> get scale {
  
  return $LikertScaleCopyWith<$Res>(_self.scale, (value) {
    return _then(_self.copyWith(scale: value));
  });
}
}


/// @nodoc
mixin _$LikertScale {

 int get min; int get max; String get minLabel; String get maxLabel;
/// Create a copy of LikertScale
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LikertScaleCopyWith<LikertScale> get copyWith => _$LikertScaleCopyWithImpl<LikertScale>(this as LikertScale, _$identity);

  /// Serializes this LikertScale to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LikertScale;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LikertScale&&(identical(other.min, _this.min) || other.min == _this.min)&&(identical(other.max, _this.max) || other.max == _this.max)&&(identical(other.minLabel, _this.minLabel) || other.minLabel == _this.minLabel)&&(identical(other.maxLabel, _this.maxLabel) || other.maxLabel == _this.maxLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LikertScale;
  return Object.hash(runtimeType,_this.min,_this.max,_this.minLabel,_this.maxLabel);
}

@override
String toString() {
  final _this = this as LikertScale;
  return 'LikertScale(min: ${_this.min}, max: ${_this.max}, minLabel: ${_this.minLabel}, maxLabel: ${_this.maxLabel})';
}


}

/// @nodoc
abstract mixin class $LikertScaleCopyWith<$Res>  {
  factory $LikertScaleCopyWith(LikertScale value, $Res Function(LikertScale) _then) = _$LikertScaleCopyWithImpl;
@useResult
$Res call({
 int min, int max, String minLabel, String maxLabel
});




}
/// @nodoc
class _$LikertScaleCopyWithImpl<$Res>
    implements $LikertScaleCopyWith<$Res> {
  _$LikertScaleCopyWithImpl(this._self, this._then);

  final LikertScale _self;
  final $Res Function(LikertScale) _then;

/// Create a copy of LikertScale
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? min = null,Object? max = null,Object? minLabel = null,Object? maxLabel = null,}) {
  return _then(LikertScale(
min: null == min ? _self.min : min // ignore: cast_nullable_to_non_nullable
as int,max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as int,minLabel: null == minLabel ? _self.minLabel : minLabel // ignore: cast_nullable_to_non_nullable
as String,maxLabel: null == maxLabel ? _self.maxLabel : maxLabel // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LikertScale].
extension LikertScalePatterns on LikertScale {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LikertScale value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LikertScale() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LikertScale value)  $default,){
final _that = this;
switch (_that) {
case _LikertScale():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LikertScale value)?  $default,){
final _that = this;
switch (_that) {
case _LikertScale() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int min,  int max,  String minLabel,  String maxLabel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LikertScale() when $default != null:
return $default(_that.min,_that.max,_that.minLabel,_that.maxLabel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int min,  int max,  String minLabel,  String maxLabel)  $default,) {final _that = this;
switch (_that) {
case _LikertScale():
return $default(_that.min,_that.max,_that.minLabel,_that.maxLabel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int min,  int max,  String minLabel,  String maxLabel)?  $default,) {final _that = this;
switch (_that) {
case _LikertScale() when $default != null:
return $default(_that.min,_that.max,_that.minLabel,_that.maxLabel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LikertScale extends LikertScale {
  const _LikertScale({required this.min, required this.max, required this.minLabel, required this.maxLabel}): super._();
  factory _LikertScale.fromJson(Map<String, dynamic> json) => _$LikertScaleFromJson(json);

@override final  int min;
@override final  int max;
@override final  String minLabel;
@override final  String maxLabel;

/// Create a copy of LikertScale
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LikertScaleCopyWith<_LikertScale> get copyWith => __$LikertScaleCopyWithImpl<_LikertScale>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LikertScaleToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LikertScale&&(identical(other.min, min) || other.min == min)&&(identical(other.max, max) || other.max == max)&&(identical(other.minLabel, minLabel) || other.minLabel == minLabel)&&(identical(other.maxLabel, maxLabel) || other.maxLabel == maxLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,min,max,minLabel,maxLabel);
}

@override
String toString() {
    return 'LikertScale(min: $min, max: $max, minLabel: $minLabel, maxLabel: $maxLabel)';
}


}

/// @nodoc
abstract mixin class _$LikertScaleCopyWith<$Res> implements $LikertScaleCopyWith<$Res> {
  factory _$LikertScaleCopyWith(_LikertScale value, $Res Function(_LikertScale) _then) = __$LikertScaleCopyWithImpl;
@override @useResult
$Res call({
 int min, int max, String minLabel, String maxLabel
});




}
/// @nodoc
class __$LikertScaleCopyWithImpl<$Res>
    implements _$LikertScaleCopyWith<$Res> {
  __$LikertScaleCopyWithImpl(this._self, this._then);

  final _LikertScale _self;
  final $Res Function(_LikertScale) _then;

/// Create a copy of LikertScale
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? min = null,Object? max = null,Object? minLabel = null,Object? maxLabel = null,}) {
  return _then(_LikertScale(
min: null == min ? _self.min : min // ignore: cast_nullable_to_non_nullable
as int,max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as int,minLabel: null == minLabel ? _self.minLabel : minLabel // ignore: cast_nullable_to_non_nullable
as String,maxLabel: null == maxLabel ? _self.maxLabel : maxLabel // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
