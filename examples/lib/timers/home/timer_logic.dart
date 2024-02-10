import 'dart:async';

import 'package:state_watcher/state_watcher.dart';

/// Computing the current date to the whole app.
final refCurrentDate = Computed(
  (watch) {
    final timer = Timer.periodic(const Duration(seconds: 1), (_) {
      watch.it((_) => DateTime.now());
    });

    watch.onDispose(timer.cancel);

    return DateTime.now();
  },
  autoDispose: true,
  debugName: 'currentDate',
);
