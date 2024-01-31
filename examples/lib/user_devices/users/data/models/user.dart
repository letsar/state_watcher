import 'package:examples/user_devices/core/data/models/identifiable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User implements Identifiable {
  const factory User({
    required int id,
    required String firstName,
    required String lastName,
    required List<int> deviceIds,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

extension UserExtensions on User {
  User newDeviceIds(List<int> Function(List<int> list) builder) {
    return copyWith(deviceIds: builder(deviceIds.toList()));
  }

  String get initials {
    return firstName.substring(0, 1) + lastName.substring(0, 1);
  }
}
