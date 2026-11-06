// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analyze_payload.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProfile {

 int get age; Gender? get gender;/// Max price per product, in Rupiah.
 int? get budgetMax;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UserProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.age, _this.age) || other.age == _this.age)&&(identical(other.gender, _this.gender) || other.gender == _this.gender)&&(identical(other.budgetMax, _this.budgetMax) || other.budgetMax == _this.budgetMax));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UserProfile;
  return Object.hash(runtimeType,_this.age,_this.gender,_this.budgetMax);
}

@override
String toString() {
  final _this = this as UserProfile;
  return 'UserProfile(age: ${_this.age}, gender: ${_this.gender}, budgetMax: ${_this.budgetMax})';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
 int age, Gender? gender, int? budgetMax
});




}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? age = null,Object? gender = freezed,Object? budgetMax = freezed,}) {
  return _then(UserProfile(
age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,budgetMax: freezed == budgetMax ? _self.budgetMax : budgetMax // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int age,  Gender? gender,  int? budgetMax)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.age,_that.gender,_that.budgetMax);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int age,  Gender? gender,  int? budgetMax)  $default,) {final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that.age,_that.gender,_that.budgetMax);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int age,  Gender? gender,  int? budgetMax)?  $default,) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.age,_that.gender,_that.budgetMax);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfile extends UserProfile {
  const _UserProfile({required this.age, this.gender, this.budgetMax}): super._();
  factory _UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

@override final  int age;
@override final  Gender? gender;
/// Max price per product, in Rupiah.
@override final  int? budgetMax;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.budgetMax, budgetMax) || other.budgetMax == budgetMax));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,age,gender,budgetMax);
}

@override
String toString() {
    return 'UserProfile(age: $age, gender: $gender, budgetMax: $budgetMax)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
 int age, Gender? gender, int? budgetMax
});




}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? age = null,Object? gender = freezed,Object? budgetMax = freezed,}) {
  return _then(_UserProfile(
age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,budgetMax: freezed == budgetMax ? _self.budgetMax : budgetMax // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$AnalyzePayload {

 UserProfile get profile;/// Question id -> Likert answer, e.g. `{"q1": 4}`.
 Map<String, int> get questionnaire;
/// Create a copy of AnalyzePayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalyzePayloadCopyWith<AnalyzePayload> get copyWith => _$AnalyzePayloadCopyWithImpl<AnalyzePayload>(this as AnalyzePayload, _$identity);

  /// Serializes this AnalyzePayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AnalyzePayload;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalyzePayload&&(identical(other.profile, _this.profile) || other.profile == _this.profile)&&const DeepCollectionEquality().equals(other.questionnaire, _this.questionnaire));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AnalyzePayload;
  return Object.hash(runtimeType,_this.profile,const DeepCollectionEquality().hash(_this.questionnaire));
}

@override
String toString() {
  final _this = this as AnalyzePayload;
  return 'AnalyzePayload(profile: ${_this.profile}, questionnaire: ${_this.questionnaire})';
}


}

/// @nodoc
abstract mixin class $AnalyzePayloadCopyWith<$Res>  {
  factory $AnalyzePayloadCopyWith(AnalyzePayload value, $Res Function(AnalyzePayload) _then) = _$AnalyzePayloadCopyWithImpl;
@useResult
$Res call({
 UserProfile profile, Map<String, int> questionnaire
});


$UserProfileCopyWith<$Res> get profile;

}
/// @nodoc
class _$AnalyzePayloadCopyWithImpl<$Res>
    implements $AnalyzePayloadCopyWith<$Res> {
  _$AnalyzePayloadCopyWithImpl(this._self, this._then);

  final AnalyzePayload _self;
  final $Res Function(AnalyzePayload) _then;

/// Create a copy of AnalyzePayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profile = null,Object? questionnaire = null,}) {
  return _then(AnalyzePayload(
profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as UserProfile,questionnaire: null == questionnaire ? _self.questionnaire : questionnaire // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}
/// Create a copy of AnalyzePayload
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res> get profile {
  
  return $UserProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// Adds pattern-matching-related methods to [AnalyzePayload].
extension AnalyzePayloadPatterns on AnalyzePayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalyzePayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalyzePayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalyzePayload value)  $default,){
final _that = this;
switch (_that) {
case _AnalyzePayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalyzePayload value)?  $default,){
final _that = this;
switch (_that) {
case _AnalyzePayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UserProfile profile,  Map<String, int> questionnaire)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalyzePayload() when $default != null:
return $default(_that.profile,_that.questionnaire);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UserProfile profile,  Map<String, int> questionnaire)  $default,) {final _that = this;
switch (_that) {
case _AnalyzePayload():
return $default(_that.profile,_that.questionnaire);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UserProfile profile,  Map<String, int> questionnaire)?  $default,) {final _that = this;
switch (_that) {
case _AnalyzePayload() when $default != null:
return $default(_that.profile,_that.questionnaire);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnalyzePayload implements AnalyzePayload {
  const _AnalyzePayload({required this.profile, required  Map<String, int> questionnaire}): _questionnaire = questionnaire;
  factory _AnalyzePayload.fromJson(Map<String, dynamic> json) => _$AnalyzePayloadFromJson(json);

@override final  UserProfile profile;
/// Question id -> Likert answer, e.g. `{"q1": 4}`.
 final  Map<String, int> _questionnaire;
/// Question id -> Likert answer, e.g. `{"q1": 4}`.
@override Map<String, int> get questionnaire {
  if (_questionnaire is EqualUnmodifiableMapView) return _questionnaire;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_questionnaire);
}


/// Create a copy of AnalyzePayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalyzePayloadCopyWith<_AnalyzePayload> get copyWith => __$AnalyzePayloadCopyWithImpl<_AnalyzePayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalyzePayloadToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalyzePayload&&(identical(other.profile, profile) || other.profile == profile)&&const DeepCollectionEquality().equals(other.questionnaire, _questionnaire));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,profile,const DeepCollectionEquality().hash(_questionnaire));
}

@override
String toString() {
    return 'AnalyzePayload(profile: $profile, questionnaire: $questionnaire)';
}


}

/// @nodoc
abstract mixin class _$AnalyzePayloadCopyWith<$Res> implements $AnalyzePayloadCopyWith<$Res> {
  factory _$AnalyzePayloadCopyWith(_AnalyzePayload value, $Res Function(_AnalyzePayload) _then) = __$AnalyzePayloadCopyWithImpl;
@override @useResult
$Res call({
 UserProfile profile, Map<String, int> questionnaire
});


@override $UserProfileCopyWith<$Res> get profile;

}
/// @nodoc
class __$AnalyzePayloadCopyWithImpl<$Res>
    implements _$AnalyzePayloadCopyWith<$Res> {
  __$AnalyzePayloadCopyWithImpl(this._self, this._then);

  final _AnalyzePayload _self;
  final $Res Function(_AnalyzePayload) _then;

/// Create a copy of AnalyzePayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profile = null,Object? questionnaire = null,}) {
  return _then(_AnalyzePayload(
profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as UserProfile,questionnaire: null == questionnaire ? _self._questionnaire : questionnaire // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}

/// Create a copy of AnalyzePayload
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res> get profile {
  
  return $UserProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}

// dart format on
