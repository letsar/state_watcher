---
title: Watchers
description: How to use the watchers.
sidebar:
  order: 4
---

Watchers are the fundamental part for interacting with Flutter when a part of your state changes.

If you just want to watch the state in a widget you can use the `WatcherBuilder` widget:

```dart
WatcherBuilder(
  builder: (context, store) {
    // Just use the watch method of the store to get the value of counter
    // and rebuild when it changes.
    final counter = store.watch(refCounter);
    return Text('$counter');
  },
);
```

If you prefer to have dedicated stateless or stateful widgets with a built-in support of stores, you can extend from `WatcherStatelessWidget` or `WatcherStatefulWidget`:

```dart
class _Counter_ extends WatcherStatelessWidget {
  const _Counter_();

  @override
  Widget build(BuildContext context, BuildStore store) {
    final counter = store.watch(refCounter);
    return Text('$counter');
  }
}
```

For the `WatcherStatefulWidget`, the store is a property of the state:

```dart
class _Counter_ extends WatcherStatefulWidget {
  const _Counter_({});

  @override
  State<_Counter_> createState() => _CounterState();
}

class _CounterState extends State<_Counter_> {
  @override
  Widget build(BuildContext context) {
    final counter = store.watch(refCounter);
    return Text('$counter');
  }
}
```

If you want to update the value of a state, you need to do it in a Watcher, but not during the build phase:
```dart
class _IncrementButton extends WatcherStatelessWidget {
  const _IncrementButton();

  @override
  Widget build(BuildContext context, BuildStore store) {
    return FloatingActionButton(
      tooltip: 'Increment',
      onPressed: () {
        store.update(refCounter, (x) => x + 1);
      },
      child: const Icon(Icons.add),
    );
  }
}
```

Sometimes we don't want to rebuild the UI but we want to execute some code when a state changes.
In this case we can use the `WatcherEffect` widget:

```dart
return WatcherEffect(
  ref: refCounter,
  onStateChanged: (context, oldValue, newValue) {
    // Do whatever you want when the value changes.
  },
);
```

We will see how to separate the business logic from the UI in the next chapter.