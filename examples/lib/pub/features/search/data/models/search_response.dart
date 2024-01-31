// ignore_for_file: invalid_annotation_target

import 'package:examples/pub/features/details/data/models/package.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_response.freezed.dart';
part 'search_response.g.dart';

@freezed
class SearchResponse with _$SearchResponse {
  const factory SearchResponse({
    required List<PackageSummary> packages,
    required String? next,
  }) = _SearchResponse;

  factory SearchResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseFromJson(json);
}

@freezed
class PackageSummary with _$PackageSummary {
  const factory PackageSummary({
    required String package,
  }) = _PackageSummary;

  factory PackageSummary.fromJson(Map<String, dynamic> json) =>
      _$PackageSummaryFromJson(json);
}

@freezed
class PackagesResponse with _$PackagesResponse {
  const factory PackagesResponse({
    required List<Package> packages,
    @JsonKey(name: 'next_url') required String? nextUrl,
  }) = _PackagesResponse;

  factory PackagesResponse.fromJson(Map<String, dynamic> json) =>
      _$PackagesResponseFromJson(json);
}
