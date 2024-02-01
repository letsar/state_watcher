import 'package:flutter/material.dart';
import 'package:state_watcher/state_watcher.dart';

// This is how we can write the default Counter app with state_watcher.

/// Reference to the counter value. Initialized to 0.
final _refCounter = Variable((_) => 0);

void main() {
  runApp(const CounterApp());
}

class CounterApp extends StatelessWidget {
  const CounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    // A store is where the actual states are stored.
    // By creating a StateStore, all descendants will have access to a store.
    return const StateStore(
      child: MaterialApp(
        home: _MyHomePage(),
      ),
    );
  }
}

class _MyHomePage extends StatelessWidget {
  const _MyHomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),

            // A WatcherBuilder is a widget that provides the nearest store to its
            // builder.
            WatcherBuilder(
              builder: (context, store) {
                // Whenever the counter value changes, this builder will be
                // called again.
                final counter = store.watch(_refCounter);
                return Text('$counter');
              },
            ),
          ],
        ),
      ),
      floatingActionButton: const _IncrementButton(),
    );
  }
}

// Instead of creating a WatcherBuilder every time, we can create a widget that
// extends WatcherStatelessWidget.
class _IncrementButton extends WatcherStatelessWidget {
  const _IncrementButton();

  @override
  Widget build(BuildContext context, BuildStore store) {
    // In the build method of a WatcherStatelessWidget, we are provided a store.
    return FloatingActionButton(
      tooltip: 'Increment',
      onPressed: () {
        // We can use the store to update the state referenced by _refCounter.
        store.update(_refCounter, (x) => x + 1);
      },
      child: const Icon(Icons.add),
    );
  }
}
