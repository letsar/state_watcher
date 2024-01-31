import 'package:examples/user_devices/devices/data/device_store.dart';
import 'package:examples/user_devices/devices/data/models/device.dart';
import 'package:examples/user_devices/users/data/models/user.dart';
import 'package:examples/user_devices/users/data/user_store.dart';
import 'package:state_watcher/state_watcher.dart';

final refDeviceAssignment = Variable((_) => DeviceAssigmentStateLogic());

class DeviceAssigmentStateLogic with StateLogic {
  DeviceAssigmentStateLogic();

  UserStore get _userStore => read(refUserStore);
  DeviceStore get _deviceStore => read(refDeviceStore);

  /// Assign the device with this [deviceId] to the user with this [userId].
  void assign(int deviceId, int userId) {
    final User user = _userStore.get(userId);
    final Device device = _deviceStore.get(deviceId);

    if (device.ownerId case final ownerId?) {
      // The device was assigned to another user before.
      // After the assignment, it should only by assigned to one person only.
      final User owner = _userStore.get(ownerId);
      final User newOwner = owner.newDeviceIds((l) => l..remove(deviceId));
      _userStore.overwrite(newOwner);
    }

    // We change the owner of the device.
    final Device newDevice = device.copyWith(ownerId: userId);

    // We assign the device to the user.
    final User newUser = user.newDeviceIds((l) => l..add(deviceId));

    // We persist the data.
    _userStore.overwrite(newUser);
    _deviceStore.overwrite(newDevice);
  }
}
