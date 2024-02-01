import 'package:flutter/material.dart';
import 'package:state_watcher/state_watcher.dart';

final _refCounter = Variable((_) => 0);

void main() {
  runApp(const CounterApp());
}

class CounterApp extends StatelessWidget {
  const CounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const StateStore(
      child: MaterialApp(
        home: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            WatcherBuilder(
              builder: (context, store) {
                return Text(
                  '${store.watch(_refCounter)}',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: const _IncrementButton(),
    );
  }
}

class _IncrementButton extends WatcherStatelessWidget {
  const _IncrementButton();

  @override
  Widget build(BuildContext context, BuildStore store) {
    return FloatingActionButton(
      tooltip: 'Increment',
      onPressed: () {
        store.update(_refCounter, (x) => x + 1);
      },
      child: const Icon(Icons.add),
    );
  }
}
