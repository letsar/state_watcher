import 'package:examples/user_devices/core/data/models/identifiable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'device.freezed.dart';
part 'device.g.dart';

@freezed
abstract class Device with _$Device implements Identifiable {
  const factory Device({
    required int id,
    required String name,
    int? ownerId,
    @Default(false) bool connected,
  }) = _Device;

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);
}
