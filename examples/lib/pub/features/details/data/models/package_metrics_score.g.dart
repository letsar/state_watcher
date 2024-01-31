// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_metrics_score.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PackageMetricsScoreImpl _$$PackageMetricsScoreImplFromJson(
        Map<String, dynamic> json) =>
    _$PackageMetricsScoreImpl(
      grantedPoints: json['grantedPoints'] as int,
      maxPoints: json['maxPoints'] as int,
      likeCount: json['likeCount'] as int,
      popularityScore: (json['popularityScore'] as num).toDouble(),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$PackageMetricsScoreImplToJson(
        _$PackageMetricsScoreImpl instance) =>
    <String, dynamic>{
      'grantedPoints': instance.grantedPoints,
      'maxPoints': instance.maxPoints,
      'likeCount': instance.likeCount,
      'popularityScore': instance.popularityScore,
      'tags': instance.tags,
    };

_$PackageMetricsResponseImpl _$$PackageMetricsResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$PackageMetricsResponseImpl(
      score:
          PackageMetricsScore.fromJson(json['score'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$PackageMetricsResponseImplToJson(
        _$PackageMetricsResponseImpl instance) =>
    <String, dynamic>{
      'score': instance.score,
    };
