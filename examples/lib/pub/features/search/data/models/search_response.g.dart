// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SearchResponseImpl _$$SearchResponseImplFromJson(Map<String, dynamic> json) =>
    _$SearchResponseImpl(
      packages: (json['packages'] as List<dynamic>)
          .map((e) => PackageSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      next: json['next'] as String?,
    );

Map<String, dynamic> _$$SearchResponseImplToJson(
        _$SearchResponseImpl instance) =>
    <String, dynamic>{
      'packages': instance.packages,
      'next': instance.next,
    };

_$PackageSummaryImpl _$$PackageSummaryImplFromJson(Map<String, dynamic> json) =>
    _$PackageSummaryImpl(
      package: json['package'] as String,
    );

Map<String, dynamic> _$$PackageSummaryImplToJson(
        _$PackageSummaryImpl instance) =>
    <String, dynamic>{
      'package': instance.package,
    };

_$PackagesResponseImpl _$$PackagesResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$PackagesResponseImpl(
      packages: (json['packages'] as List<dynamic>)
          .map((e) => Package.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextUrl: json['next_url'] as String?,
    );

Map<String, dynamic> _$$PackagesResponseImplToJson(
        _$PackagesResponseImpl instance) =>
    <String, dynamic>{
      'packages': instance.packages,
      'next_url': instance.nextUrl,
    };
