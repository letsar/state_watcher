# state_watcher
A simple, yet powerful reactive state management solution for Flutter applications

# Guide

We can see an application state as the agglomeration of a multitude of tiny states. At the core of this vision, we have independent states we can read and write. For example in the counter app, the whole application has only one indepedent state: *the counter*.

In **state_watcher**, such a state is declared by a `Variable`:

```dart
// We declare here a state which has an initial value of 0, and it can be referenced through `refCounter`.
final refCounter = Variable((_) => 0);
```

The actual state is stored in something called a **Scope**. For that, in Flutter, we can declare a new scope, in the widget tree, with a `StateScope` widget:

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // The root scope can be declared just above the MaterialApp, so that it can be accessed from anywhere in the application.
    return const StateScope(
      child: MaterialApp(
        home: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}
```

Then in order to display the value of our counter, we need to get the scope. We can do that in any widget, with a `StateWatcher`!

```dart
StateWatcher(
  builder: (BuildContext context, BuildScope scope) {
    // Thanks to the StateWatcher, we get the scope from the nearest StateScope ancestor.
    // With this scope we can watch the state referenced by `refCounter`.
    // Whenever the state changes, the builder of the StateWatcher will be called again.
    final counter = scope.watch(refCounter);
    return Text('$counter');
  },
),
```

Now we need to be able to update the actual state, to do that we still need a scope.
We could create another `StateWatcher` and use the scope to update the value, but it can be cumbersome to deal with builder widgets.
Instead we will create a dedicated widget extending `WatcherStatelessWidget`!
A `WatcherStatelessWidget` is like a `StatelessWidget` except it has a different signature for the build method, in which we can get the scope:

```dart
class _IncrementButton extends WatcherStatelessWidget {
  const _IncrementButton();

  @override
  Widget build(BuildContext context, BuildScope scope) {
    // As with StateWatcher we can get the scope.
    return FloatingActionButton(
      tooltip: 'Increment',
      onPressed: () {
        // We can then use the update method to changes the UI.
        scope.update(refCounter, (x) => x + 1);
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

And we can watch it like a `Variable`:

```dart
class _DivisibleByThree extends WatcherStatelessWidget {
  const _DivisibleByThree();

  @override
  Widget build(BuildContext context, BuildScope scope) {
    final divisibleByThree = scope.watch(refDivisibleByThree);
    return Text('$divisibleByThree');
  }
}
```

By default, the `_DivisibleByThree` widget is only rebuild when the new computed value is different than the previous one. So when the counter goes from 7 to 8, the `_DivisibleByThree` widget is not rebuilt because `divisibleByThree` is `false` for both values. 


For a more detailed documentation hit the official site: // TODO.


## DevTools