import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

part 'package_version.freezed.dart';
part 'package_version.g.dart';

@freezed
class PackageVersion with _$PackageVersion {
  factory PackageVersion({
    required String version,
    required Pubspec pubspec,
  }) = _PackageVersion;

  factory PackageVersion.fromJson(Map<String, Object?> json) =>
      _$PackageVersionFromJson(json);
}
