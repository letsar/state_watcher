import 'package:examples/user_devices/core/data/store.dart';
import 'package:examples/user_devices/devices/data/models/device.dart';
import 'package:examples/user_devices/devices/data/sources/device_api.dart';
import 'package:state_watcher/state_watcher.dart';

final refDeviceMap = Variable((_) => const <int, Device>{});
final refDeviceStore = Variable((_) => DeviceStore());

class DeviceStore extends Store<Device> {
  DeviceStore() : super(refDeviceMap);

  DeviceApi get _apiClient => read(refDeviceApi);

  @override
  Future<Iterable<Device>> fetch() {
    return _apiClient.fetchDevices();
  }
}
