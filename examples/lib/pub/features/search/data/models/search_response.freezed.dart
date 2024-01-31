// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

SearchResponse _$SearchResponseFromJson(Map<String, dynamic> json) {
  return _SearchResponse.fromJson(json);
}

/// @nodoc
mixin _$SearchResponse {
  List<PackageSummary> get packages => throw _privateConstructorUsedError;
  String? get next => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SearchResponseCopyWith<SearchResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchResponseCopyWith<$Res> {
  factory $SearchResponseCopyWith(
          SearchResponse value, $Res Function(SearchResponse) then) =
      _$SearchResponseCopyWithImpl<$Res, SearchResponse>;
  @useResult
  $Res call({List<PackageSummary> packages, String? next});
}

/// @nodoc
class _$SearchResponseCopyWithImpl<$Res, $Val extends SearchResponse>
    implements $SearchResponseCopyWith<$Res> {
  _$SearchResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? packages = null,
    Object? next = freezed,
  }) {
    return _then(_value.copyWith(
      packages: null == packages
          ? _value.packages
          : packages // ignore: cast_nullable_to_non_nullable
              as List<PackageSummary>,
      next: freezed == next
          ? _value.next
          : next // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SearchResponseImplCopyWith<$Res>
    implements $SearchResponseCopyWith<$Res> {
  factory _$$SearchResponseImplCopyWith(_$SearchResponseImpl value,
          $Res Function(_$SearchResponseImpl) then) =
      __$$SearchResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<PackageSummary> packages, String? next});
}

/// @nodoc
class __$$SearchResponseImplCopyWithImpl<$Res>
    extends _$SearchResponseCopyWithImpl<$Res, _$SearchResponseImpl>
    implements _$$SearchResponseImplCopyWith<$Res> {
  __$$SearchResponseImplCopyWithImpl(
      _$SearchResponseImpl _value, $Res Function(_$SearchResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? packages = null,
    Object? next = freezed,
  }) {
    return _then(_$SearchResponseImpl(
      packages: null == packages
          ? _value._packages
          : packages // ignore: cast_nullable_to_non_nullable
              as List<PackageSummary>,
      next: freezed == next
          ? _value.next
          : next // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SearchResponseImpl implements _SearchResponse {
  const _$SearchResponseImpl(
      {required final List<PackageSummary> packages, required this.next})
      : _packages = packages;

  factory _$SearchResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$SearchResponseImplFromJson(json);

  final List<PackageSummary> _packages;
  @override
  List<PackageSummary> get packages {
    if (_packages is EqualUnmodifiableListView) return _packages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_packages);
  }

  @override
  final String? next;

  @override
  String toString() {
    return 'SearchResponse(packages: $packages, next: $next)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchResponseImpl &&
            const DeepCollectionEquality().equals(other._packages, _packages) &&
            (identical(other.next, next) || other.next == next));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_packages), next);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchResponseImplCopyWith<_$SearchResponseImpl> get copyWith =>
      __$$SearchResponseImplCopyWithImpl<_$SearchResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SearchResponseImplToJson(
      this,
    );
  }
}

abstract class _SearchResponse implements SearchResponse {
  const factory _SearchResponse(
      {required final List<PackageSummary> packages,
      required final String? next}) = _$SearchResponseImpl;

  factory _SearchResponse.fromJson(Map<String, dynamic> json) =
      _$SearchResponseImpl.fromJson;

  @override
  List<PackageSummary> get packages;
  @override
  String? get next;
  @override
  @JsonKey(ignore: true)
  _$$SearchResponseImplCopyWith<_$SearchResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PackageSummary _$PackageSummaryFromJson(Map<String, dynamic> json) {
  return _PackageSummary.fromJson(json);
}

/// @nodoc
mixin _$PackageSummary {
  String get package => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PackageSummaryCopyWith<PackageSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PackageSummaryCopyWith<$Res> {
  factory $PackageSummaryCopyWith(
          PackageSummary value, $Res Function(PackageSummary) then) =
      _$PackageSummaryCopyWithImpl<$Res, PackageSummary>;
  @useResult
  $Res call({String package});
}

/// @nodoc
class _$PackageSummaryCopyWithImpl<$Res, $Val extends PackageSummary>
    implements $PackageSummaryCopyWith<$Res> {
  _$PackageSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? package = null,
  }) {
    return _then(_value.copyWith(
      package: null == package
          ? _value.package
          : package // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PackageSummaryImplCopyWith<$Res>
    implements $PackageSummaryCopyWith<$Res> {
  factory _$$PackageSummaryImplCopyWith(_$PackageSummaryImpl value,
          $Res Function(_$PackageSummaryImpl) then) =
      __$$PackageSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String package});
}

/// @nodoc
class __$$PackageSummaryImplCopyWithImpl<$Res>
    extends _$PackageSummaryCopyWithImpl<$Res, _$PackageSummaryImpl>
    implements _$$PackageSummaryImplCopyWith<$Res> {
  __$$PackageSummaryImplCopyWithImpl(
      _$PackageSummaryImpl _value, $Res Function(_$PackageSummaryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? package = null,
  }) {
    return _then(_$PackageSummaryImpl(
      package: null == package
          ? _value.package
          : package // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PackageSummaryImpl implements _PackageSummary {
  const _$PackageSummaryImpl({required this.package});

  factory _$PackageSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PackageSummaryImplFromJson(json);

  @override
  final String package;

  @override
  String toString() {
    return 'PackageSummary(package: $package)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PackageSummaryImpl &&
            (identical(other.package, package) || other.package == package));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, package);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PackageSummaryImplCopyWith<_$PackageSummaryImpl> get copyWith =>
      __$$PackageSummaryImplCopyWithImpl<_$PackageSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PackageSummaryImplToJson(
      this,
    );
  }
}

abstract class _PackageSummary implements PackageSummary {
  const factory _PackageSummary({required final String package}) =
      _$PackageSummaryImpl;

  factory _PackageSummary.fromJson(Map<String, dynamic> json) =
      _$PackageSummaryImpl.fromJson;

  @override
  String get package;
  @override
  @JsonKey(ignore: true)
  _$$PackageSummaryImplCopyWith<_$PackageSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PackagesResponse _$PackagesResponseFromJson(Map<String, dynamic> json) {
  return _PackagesResponse.fromJson(json);
}

/// @nodoc
mixin _$PackagesResponse {
  List<Package> get packages => throw _privateConstructorUsedError;
  @JsonKey(name: 'next_url')
  String? get nextUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PackagesResponseCopyWith<PackagesResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PackagesResponseCopyWith<$Res> {
  factory $PackagesResponseCopyWith(
          PackagesResponse value, $Res Function(PackagesResponse) then) =
      _$PackagesResponseCopyWithImpl<$Res, PackagesResponse>;
  @useResult
  $Res call(
      {List<Package> packages, @JsonKey(name: 'next_url') String? nextUrl});
}

/// @nodoc
class _$PackagesResponseCopyWithImpl<$Res, $Val extends PackagesResponse>
    implements $PackagesResponseCopyWith<$Res> {
  _$PackagesResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? packages = null,
    Object? nextUrl = freezed,
  }) {
    return _then(_value.copyWith(
      packages: null == packages
          ? _value.packages
          : packages // ignore: cast_nullable_to_non_nullable
              as List<Package>,
      nextUrl: freezed == nextUrl
          ? _value.nextUrl
          : nextUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PackagesResponseImplCopyWith<$Res>
    implements $PackagesResponseCopyWith<$Res> {
  factory _$$PackagesResponseImplCopyWith(_$PackagesResponseImpl value,
          $Res Function(_$PackagesResponseImpl) then) =
      __$$PackagesResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Package> packages, @JsonKey(name: 'next_url') String? nextUrl});
}

/// @nodoc
class __$$PackagesResponseImplCopyWithImpl<$Res>
    extends _$PackagesResponseCopyWithImpl<$Res, _$PackagesResponseImpl>
    implements _$$PackagesResponseImplCopyWith<$Res> {
  __$$PackagesResponseImplCopyWithImpl(_$PackagesResponseImpl _value,
      $Res Function(_$PackagesResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? packages = null,
    Object? nextUrl = freezed,
  }) {
    return _then(_$PackagesResponseImpl(
      packages: null == packages
          ? _value._packages
          : packages // ignore: cast_nullable_to_non_nullable
              as List<Package>,
      nextUrl: freezed == nextUrl
          ? _value.nextUrl
          : nextUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PackagesResponseImpl implements _PackagesResponse {
  const _$PackagesResponseImpl(
      {required final List<Package> packages,
      @JsonKey(name: 'next_url') required this.nextUrl})
      : _packages = packages;

  factory _$PackagesResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$PackagesResponseImplFromJson(json);

  final List<Package> _packages;
  @override
  List<Package> get packages {
    if (_packages is EqualUnmodifiableListView) return _packages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_packages);
  }

  @override
  @JsonKey(name: 'next_url')
  final String? nextUrl;

  @override
  String toString() {
    return 'PackagesResponse(packages: $packages, nextUrl: $nextUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PackagesResponseImpl &&
            const DeepCollectionEquality().equals(other._packages, _packages) &&
            (identical(other.nextUrl, nextUrl) || other.nextUrl == nextUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_packages), nextUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PackagesResponseImplCopyWith<_$PackagesResponseImpl> get copyWith =>
      __$$PackagesResponseImplCopyWithImpl<_$PackagesResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PackagesResponseImplToJson(
      this,
    );
  }
}

abstract class _PackagesResponse implements PackagesResponse {
  const factory _PackagesResponse(
          {required final List<Package> packages,
          @JsonKey(name: 'next_url') required final String? nextUrl}) =
      _$PackagesResponseImpl;

  factory _PackagesResponse.fromJson(Map<String, dynamic> json) =
      _$PackagesResponseImpl.fromJson;

  @override
  List<Package> get packages;
  @override
  @JsonKey(name: 'next_url')
  String? get nextUrl;
  @override
  @JsonKey(ignore: true)
  _$$PackagesResponseImplCopyWith<_$PackagesResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
