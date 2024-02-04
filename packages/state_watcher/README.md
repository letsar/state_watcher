[![Build & Tests][github_action_build_badge]][github_action_build]
[![Codecov][codecov_badge]][codecov]
[![Pub][pub_badge]][pub]

<p align="center">
  <img src="https://raw.githubusercontent.com/letsar/state_watcher/main/resources/images/logo_and_text.png" width="100%" alt="state_watcher logo" />
</p>

---

A simple, yet powerful reactive state management solution for Flutter applications

For a more detailed documentation hit the official [site](https://letsar.github.io/state_watcher/).

# Guide

We can see an application state as the agglomeration of a multitude of tiny states. At the core of this vision, we have independent states we can read and write. For example in the counter app, the whole application has only one indepedent state: *the counter*.

In **state_watcher**, such a state is declared by a `Provided`:

```dart
// We declare here a state which has an initial value of 0, and it can be referenced through `refCounter`.
final refCounter = Provided((_) => 0);
```

The actual state is stored in something called a **Store**. For that, in Flutter, we can declare a new store, in the widget tree, with a `StateStore` widget:

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // The root store can be declared just above the MaterialApp, so that it can be accessed from anywhere in the application.
    return const StateStore(
      child: MaterialApp(
        home: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}
```

Then in order to display the value of our counter, we need to get the store. We can do that in any widget, with a `WatcherBuilder`!

```dart
WatcherBuilder(
  builder: (BuildContext context, BuildStore store) {
    // Thanks to the WatcherBuilder, we get the store from the nearest StateStore ancestor.
    // With this store we can watch the state referenced by `refCounter`.
    // Whenever the state changes, the builder of the WatcherBuilder will be called again.
    final counter = store.watch(refCounter);
    return Text('$counter');
  },
),
```

Now we need to be able to update the actual state, to do that we still need a store.
We could create another `WatcherBuilder` and use the store to update the value, but it can be cumbersome to deal with builder widgets.
Instead we will create a dedicated widget extending `WatcherStatelessWidget`!
A `WatcherStatelessWidget` is like a `StatelessWidget` except it has a different signature for the build method, in which we can get the store:

```dart
class _IncrementButton extends WatcherStatelessWidget {
  const _IncrementButton();

  @override
  Widget build(BuildContext context, BuildStore store) {
    // As with WatcherBuilder we can get the store.
    return FloatingActionButton(
      tooltip: 'Increment',
      onPressed: () {
        // We can then use the update method to changes the UI.
        store.update(refCounter, (x) => x + 1);
      },
      child: const Icon(Icons.add),
    );
  }
}
```

We saw the bare minimum to create an application using **state_watcher**, but what if we want to create a derived state?
For example let's say we want another widget displaying whether the counter can be divided by 3.

Such a state is declared by a `Computed`:

```dart
final refDivisibleByThree = Computed((watch) {
  final counter = watch(refCounter);
  final divisibleByThree = (counter % 3) == 0;
  return divisibleByThree;
});
```

And we can watch it like a `Provided`:

```dart
class _DivisibleByThree extends WatcherStatelessWidget {
  const _DivisibleByThree();

  @override
  Widget build(BuildContext context, BuildStore store) {
    final divisibleByThree = store.watch(refDivisibleByThree);
    return Text('$divisibleByThree');
  }
}
```

By default, the `_DivisibleByThree` widget is only rebuild when the new computed value is different than the previous one. So when the counter goes from 7 to 8, the `_DivisibleByThree` widget is not rebuilt because `divisibleByThree` is `false` for both values. 

## DevTools

**state_watcher** has a DevTools extension allowing you to easily debug the state changes in your app and see which is the state responsible for a widget to rebuild.

![DevTools extension][devtools_extension]


<!-- Links -->
[github_action_build_badge]: https://github.com/letsar/state_watcher/workflows/Build/badge.svg
[github_action_build]: https://github.com/letsar/state_watcher/actions/workflows/state_watcher_build.yml
[github_action_test_badge]: https://github.com/letsar/state_watcher/workflows/Test/badge.svg
[github_action_test]: https://github.com/letsar/state_watcher/actions/workflows/state_watcher_test.yml
[pub_badge]: https://img.shields.io/pub/v/state_watcher.svg
[pub]: https://pub.dartlang.org/packages/state_watcher
[codecov]: https://codecov.io/gh/letsar/state_watcher
[codecov_badge]: https://codecov.io/gh/letsar/state_watcher/graph/badge.svg?token=OCDC7QXE0B
[issue]: https://github.com/letsar/state_watcher/issues
[pr]: https://github.com/letsar/state_watcher/pulls
[devtools_extension]: https://raw.githubusercontent.com/letsar/state_watcher/main/resources/images/devtools_extension.png
