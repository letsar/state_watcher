import 'dart:async';

import 'package:state_watcher/state_watcher.dart';

final _refCurrentDate = Provided((_) => DateTime.now(), autoDispose: true);
final refTimerLogic = Provided(
  (_) => TimerLogic()..start(),
  autoDispose: true,
);

class TimerLogic with StateLogic {
  Timer? timer;

  void start() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      update(_refCurrentDate, (_) => DateTime.now());
    });
  }

  Ref<DateTime> get refCurrentDate => _refCurrentDate;

  @override
  void dispose() {
    timer?.cancel();
    timer = null;
    super.dispose();
  }
}
