import 'package:examples/pub/features/details/data/models/package_version.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'package.freezed.dart';
part 'package.g.dart';

@freezed
class Package with _$Package {
  const factory Package({
    required String name,
    required PackageVersion latest,
  }) = _Package;

  factory Package.fromJson(Map<String, dynamic> json) =>
      _$PackageFromJson(json);
}
