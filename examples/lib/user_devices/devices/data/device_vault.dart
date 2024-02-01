import 'package:examples/user_devices/core/data/vault.dart';
import 'package:examples/user_devices/devices/data/models/device.dart';
import 'package:examples/user_devices/devices/data/sources/device_api.dart';
import 'package:state_watcher/state_watcher.dart';

final refDeviceMap = Variable((_) => const <int, Device>{});
final refDeviceVault = Variable((_) => DeviceVault());

class DeviceVault extends Vault<Device> {
  DeviceVault() : super(refDeviceMap);

  DeviceApi get _apiClient => read(refDeviceApi);

  @override
  Future<Iterable<Device>> fetch() {
    return _apiClient.fetchDevices();
  }
}
