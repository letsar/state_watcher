---
title: StateLogic
description: What is StateLogic.
sidebar:
  order: 5
---

We saw how to update our widgets and how ref, but it would be better if we could separate the whole logic of updating our states from the UI.

In **state_watcher** we can do it by creating a Variable with an object applying a specific mixin called `StateLogic`:

```dart
final refCounter = Variable((_) => 0);
final refCounterStateLogic = Variable((_) => CounterStateLogic());

class CounterStateLogic with StateLogic {
  void incrementCounter() {
    update(_refCounter, (x) => x + 1);
  }
}

class _IncrementButton extends WatcherStatelessWidget {
  const _IncrementButton();

  @override
  Widget build(BuildContext context, BuildStore store) {
    return FloatingActionButton(
      tooltip: 'Increment',
      onPressed: () {
        store.read(refCounterStateLogic).incrementCounter();
      },
      child: const Icon(Icons.add),
    );
  }
}
```

:::tip
A `StateLogic` has a `dispose` method you can override if you need to do some stuff before it is removed from its store.
:::