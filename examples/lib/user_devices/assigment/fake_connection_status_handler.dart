import 'dart:async';
import 'dart:math';

import 'package:examples/common/loadable.dart';
import 'package:examples/user_devices/devices/data/device_vault.dart';
import 'package:examples/user_devices/devices/data/models/device.dart';
import 'package:state_watcher/state_watcher.dart';

final refConnectionStatusHandler =
    Provided((_) => FakeConnectionStatusHandler());

class FakeConnectionStatusHandler
    with StateLogic
    implements Loadable, Disposable {
  FakeConnectionStatusHandler();

  DeviceVault get _deviceStore => read(refDeviceVault);
  Timer? _timer;
  final Random _rnd = Random();

  @override
  Future<void> load() async {
    _timer = Timer(const Duration(seconds: 2), _changeOneConnectionStatus);
  }

  void _changeOneConnectionStatus() {
    final Device randomDevice =
        _deviceStore.values[_rnd.nextInt(_deviceStore.length)];

    _deviceStore
        .overwrite(randomDevice.copyWith(connected: !randomDevice.connected));
    load();
  }

  @override
  void dispose() {
    _timer?.cancel();
  }
}
