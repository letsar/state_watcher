import 'package:examples/user_devices/core/data/sources/fake_api.dart';
import 'package:examples/user_devices/devices/data/models/device.dart';
import 'package:state_watcher/state_watcher.dart';

final refDeviceApi = Provided((_) => DeviceApi());

const List<Device> _devices = <Device>[
  Device(id: 1, name: 'Device 1'),
  Device(id: 2, name: 'Device 2', ownerId: 1),
  Device(id: 3, name: 'Device 3', ownerId: 4),
  Device(id: 4, name: 'Device 4', ownerId: 4),
  Device(id: 5, name: 'Device 5'),
  Device(id: 6, name: 'Device 6'),
  Device(id: 7, name: 'Device 7'),
  Device(id: 8, name: 'Device 8'),
  Device(id: 9, name: 'Device 9'),
];

class DeviceApi extends FakeApi {
  Future<List<Device>> fetchDevices() => delay(_devices);
}
