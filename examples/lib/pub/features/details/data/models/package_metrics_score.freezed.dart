// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'package_metrics_score.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

PackageMetricsScore _$PackageMetricsScoreFromJson(Map<String, dynamic> json) {
  return _PackageMetricsScore.fromJson(json);
}

/// @nodoc
mixin _$PackageMetricsScore {
  int get grantedPoints => throw _privateConstructorUsedError;
  int get maxPoints => throw _privateConstructorUsedError;
  int get likeCount => throw _privateConstructorUsedError;
  double get popularityScore => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PackageMetricsScoreCopyWith<PackageMetricsScore> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PackageMetricsScoreCopyWith<$Res> {
  factory $PackageMetricsScoreCopyWith(
          PackageMetricsScore value, $Res Function(PackageMetricsScore) then) =
      _$PackageMetricsScoreCopyWithImpl<$Res, PackageMetricsScore>;
  @useResult
  $Res call(
      {int grantedPoints,
      int maxPoints,
      int likeCount,
      double popularityScore,
      List<String> tags});
}

/// @nodoc
class _$PackageMetricsScoreCopyWithImpl<$Res, $Val extends PackageMetricsScore>
    implements $PackageMetricsScoreCopyWith<$Res> {
  _$PackageMetricsScoreCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? grantedPoints = null,
    Object? maxPoints = null,
    Object? likeCount = null,
    Object? popularityScore = null,
    Object? tags = null,
  }) {
    return _then(_value.copyWith(
      grantedPoints: null == grantedPoints
          ? _value.grantedPoints
          : grantedPoints // ignore: cast_nullable_to_non_nullable
              as int,
      maxPoints: null == maxPoints
          ? _value.maxPoints
          : maxPoints // ignore: cast_nullable_to_non_nullable
              as int,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      popularityScore: null == popularityScore
          ? _value.popularityScore
          : popularityScore // ignore: cast_nullable_to_non_nullable
              as double,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PackageMetricsScoreImplCopyWith<$Res>
    implements $PackageMetricsScoreCopyWith<$Res> {
  factory _$$PackageMetricsScoreImplCopyWith(_$PackageMetricsScoreImpl value,
          $Res Function(_$PackageMetricsScoreImpl) then) =
      __$$PackageMetricsScoreImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int grantedPoints,
      int maxPoints,
      int likeCount,
      double popularityScore,
      List<String> tags});
}

/// @nodoc
class __$$PackageMetricsScoreImplCopyWithImpl<$Res>
    extends _$PackageMetricsScoreCopyWithImpl<$Res, _$PackageMetricsScoreImpl>
    implements _$$PackageMetricsScoreImplCopyWith<$Res> {
  __$$PackageMetricsScoreImplCopyWithImpl(_$PackageMetricsScoreImpl _value,
      $Res Function(_$PackageMetricsScoreImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? grantedPoints = null,
    Object? maxPoints = null,
    Object? likeCount = null,
    Object? popularityScore = null,
    Object? tags = null,
  }) {
    return _then(_$PackageMetricsScoreImpl(
      grantedPoints: null == grantedPoints
          ? _value.grantedPoints
          : grantedPoints // ignore: cast_nullable_to_non_nullable
              as int,
      maxPoints: null == maxPoints
          ? _value.maxPoints
          : maxPoints // ignore: cast_nullable_to_non_nullable
              as int,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      popularityScore: null == popularityScore
          ? _value.popularityScore
          : popularityScore // ignore: cast_nullable_to_non_nullable
              as double,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PackageMetricsScoreImpl implements _PackageMetricsScore {
  const _$PackageMetricsScoreImpl(
      {required this.grantedPoints,
      required this.maxPoints,
      required this.likeCount,
      required this.popularityScore,
      required final List<String> tags})
      : _tags = tags;

  factory _$PackageMetricsScoreImpl.fromJson(Map<String, dynamic> json) =>
      _$$PackageMetricsScoreImplFromJson(json);

  @override
  final int grantedPoints;
  @override
  final int maxPoints;
  @override
  final int likeCount;
  @override
  final double popularityScore;
  final List<String> _tags;
  @override
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  String toString() {
    return 'PackageMetricsScore(grantedPoints: $grantedPoints, maxPoints: $maxPoints, likeCount: $likeCount, popularityScore: $popularityScore, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PackageMetricsScoreImpl &&
            (identical(other.grantedPoints, grantedPoints) ||
                other.grantedPoints == grantedPoints) &&
            (identical(other.maxPoints, maxPoints) ||
                other.maxPoints == maxPoints) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.popularityScore, popularityScore) ||
                other.popularityScore == popularityScore) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, grantedPoints, maxPoints,
      likeCount, popularityScore, const DeepCollectionEquality().hash(_tags));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PackageMetricsScoreImplCopyWith<_$PackageMetricsScoreImpl> get copyWith =>
      __$$PackageMetricsScoreImplCopyWithImpl<_$PackageMetricsScoreImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PackageMetricsScoreImplToJson(
      this,
    );
  }
}

abstract class _PackageMetricsScore implements PackageMetricsScore {
  const factory _PackageMetricsScore(
      {required final int grantedPoints,
      required final int maxPoints,
      required final int likeCount,
      required final double popularityScore,
      required final List<String> tags}) = _$PackageMetricsScoreImpl;

  factory _PackageMetricsScore.fromJson(Map<String, dynamic> json) =
      _$PackageMetricsScoreImpl.fromJson;

  @override
  int get grantedPoints;
  @override
  int get maxPoints;
  @override
  int get likeCount;
  @override
  double get popularityScore;
  @override
  List<String> get tags;
  @override
  @JsonKey(ignore: true)
  _$$PackageMetricsScoreImplCopyWith<_$PackageMetricsScoreImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PackageMetricsResponse _$PackageMetricsResponseFromJson(
    Map<String, dynamic> json) {
  return _PackageMetricsResponse.fromJson(json);
}

/// @nodoc
mixin _$PackageMetricsResponse {
  PackageMetricsScore get score => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PackageMetricsResponseCopyWith<PackageMetricsResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PackageMetricsResponseCopyWith<$Res> {
  factory $PackageMetricsResponseCopyWith(PackageMetricsResponse value,
          $Res Function(PackageMetricsResponse) then) =
      _$PackageMetricsResponseCopyWithImpl<$Res, PackageMetricsResponse>;
  @useResult
  $Res call({PackageMetricsScore score});

  $PackageMetricsScoreCopyWith<$Res> get score;
}

/// @nodoc
class _$PackageMetricsResponseCopyWithImpl<$Res,
        $Val extends PackageMetricsResponse>
    implements $PackageMetricsResponseCopyWith<$Res> {
  _$PackageMetricsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? score = null,
  }) {
    return _then(_value.copyWith(
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as PackageMetricsScore,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PackageMetricsScoreCopyWith<$Res> get score {
    return $PackageMetricsScoreCopyWith<$Res>(_value.score, (value) {
      return _then(_value.copyWith(score: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PackageMetricsResponseImplCopyWith<$Res>
    implements $PackageMetricsResponseCopyWith<$Res> {
  factory _$$PackageMetricsResponseImplCopyWith(
          _$PackageMetricsResponseImpl value,
          $Res Function(_$PackageMetricsResponseImpl) then) =
      __$$PackageMetricsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({PackageMetricsScore score});

  @override
  $PackageMetricsScoreCopyWith<$Res> get score;
}

/// @nodoc
class __$$PackageMetricsResponseImplCopyWithImpl<$Res>
    extends _$PackageMetricsResponseCopyWithImpl<$Res,
        _$PackageMetricsResponseImpl>
    implements _$$PackageMetricsResponseImplCopyWith<$Res> {
  __$$PackageMetricsResponseImplCopyWithImpl(
      _$PackageMetricsResponseImpl _value,
      $Res Function(_$PackageMetricsResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? score = null,
  }) {
    return _then(_$PackageMetricsResponseImpl(
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as PackageMetricsScore,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PackageMetricsResponseImpl implements _PackageMetricsResponse {
  _$PackageMetricsResponseImpl({required this.score});

  factory _$PackageMetricsResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$PackageMetricsResponseImplFromJson(json);

  @override
  final PackageMetricsScore score;

  @override
  String toString() {
    return 'PackageMetricsResponse(score: $score)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PackageMetricsResponseImpl &&
            (identical(other.score, score) || other.score == score));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, score);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PackageMetricsResponseImplCopyWith<_$PackageMetricsResponseImpl>
      get copyWith => __$$PackageMetricsResponseImplCopyWithImpl<
          _$PackageMetricsResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PackageMetricsResponseImplToJson(
      this,
    );
  }
}

abstract class _PackageMetricsResponse implements PackageMetricsResponse {
  factory _PackageMetricsResponse({required final PackageMetricsScore score}) =
      _$PackageMetricsResponseImpl;

  factory _PackageMetricsResponse.fromJson(Map<String, dynamic> json) =
      _$PackageMetricsResponseImpl.fromJson;

  @override
  PackageMetricsScore get score;
  @override
  @JsonKey(ignore: true)
  _$$PackageMetricsResponseImplCopyWith<_$PackageMetricsResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
