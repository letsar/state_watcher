// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_version.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PackageVersionImpl _$$PackageVersionImplFromJson(Map<String, dynamic> json) =>
    _$PackageVersionImpl(
      version: json['version'] as String,
      pubspec: Pubspec.fromJson(json['pubspec'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$PackageVersionImplToJson(
        _$PackageVersionImpl instance) =>
    <String, dynamic>{
      'version': instance.version,
      'pubspec': instance.pubspec,
    };
