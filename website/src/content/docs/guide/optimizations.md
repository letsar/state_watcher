---
title: Optimizations
description: How to optimize performances and memory
sidebar:
  order: 3
---

By default, the APIs in **state_watcher** will favor efficiency and simplicity of usage, over pure performance. This means that sometimes, to have the best performance, manual configuration will be necessary.

Here you will find how to configure **state_watcher** in you app, to fine-tuning its performance.

# Lifting state up

By default, the state of `Computed` refs are stored in the nearest `StateStore` in the widget tree. This is useful to be sure to watch the right values in the `Computed`'s callback.
Sometimes you know that the state of a `Computed` can be globally available and you do not want it to be saved in the nearest store in the widget tree, but in the root one. It can be particularly true when using `Computed.withParameter`.

To do that you'll have to set the `global` parameter to `true`:
```dart
Computed((watch) {
  return watch(refCounter);
}, global: true);
```

# Disposing Provided states automatically

By default the state of a `Provided` is not removed from the store when nothing watches it. You can opt-in for this feature by setting `autoDispose` to true when creating the `Provided`.
```dart
final refCurrentDate = Provided((_) {
  return DateTime.now();
},
autoDispose: true);
```

# Stopping watching refs

In some conditions, we know that after a certain state, we don't need to watch it anymore. For example if you have a widget which shows an expiration duration, once it's expired, we do not need to watch the current date anymore.

To unwatch a ref you can call the `watch.cancel` method with that ref:
```dart
/// Computing the duration left by the expiration date.
final _refCurrentDurationLeft = Computed.withParameter(
  (watch, DateTime expirationDate) {
    // Getting the current date, automatically updated every second.
    final currentDate = watch(refCurrentDate);
    final duration = expirationDate.difference(currentDate);

    if (duration.inSeconds < 1) {
      // Calling cancel to stop watching refCurrentDate once expired.
      watch.cancel(refCurrentDate);
      return 'Expired';
    }

    return duration;
  },
  global: true,
);
```

By doing this, if `refCurrentDate` is automatically disposed, when every widget is expired, the state of `refCurrentDate` will be disposed.

