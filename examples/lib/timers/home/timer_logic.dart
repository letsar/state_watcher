import 'dart:async';

import 'package:state_watcher/state_watcher.dart';

/// Providing the current date to the whole app.
final refCurrentDate = Provided(
  (read) {
    // Trick to start the timer logic the first time
    // this state is read and not present in the store.
    read(_refTimerLogic);
    return DateTime.now();
  },
  autoDispose: true,
  debugName: 'currentDate',
);

/// Providing the timer logic which updates the current date every second.
/// It is private because we don't want to expose it.
final _refTimerLogic = Provided(
  (_) => _TimerLogic()..start(),
  autoDispose: true,
  debugName: '_timerLogic',
);

class _TimerLogic with StateLogic {
  Timer? timer;

  void start() {
    // Every second we update the current date.
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      update(refCurrentDate, (_) => DateTime.now());
    });
  }

  @override
  void dispose() {
    // Called when the logic is removed from the store.
    timer?.cancel();
    timer = null;
    super.dispose();
  }
}
