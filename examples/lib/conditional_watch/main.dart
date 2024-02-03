import 'package:flutter/material.dart';
import 'package:state_watcher/state_watcher.dart';

final _refCounterA = Provided((_) => 0, debugName: 'counterA');
final _refCounterB = Provided((_) => 0, debugName: 'counterB');
final _refCounterX = Provided((_) => _refCounterA, debugName: 'counterX');
final _refAppStateLogic = Provided((_) => AppStateLogic());

class AppStateLogic with StateLogic {
  AppStateLogic();

  void setCounterRef(Provided<int> ref) {
    write(_refCounterX, ref);
  }

  void incrementCounter(Provided<int> refToCounter) {
    update(refToCounter, (x) => x + 1);
  }
}

void main() {
  runApp(const ConditionalWatchApp());
}

class ConditionalWatchApp extends StatelessWidget {
  const ConditionalWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StateStore(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: const Column(
        children: [
          Expanded(
            flex: 1,
            child: _Counters(),
          ),
          Expanded(
            flex: 2,
            child: _CurrentCounter(),
          ),
        ],
      ),
    );
  }
}

class _Counters extends StatelessWidget {
  const _Counters();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _SelectableCounter(
            refCounter: _refCounterA,
          ),
        ),
        Expanded(
          child: _SelectableCounter(
            refCounter: _refCounterB,
          ),
        ),
      ],
    );
  }
}

class _SelectableCounter extends WatcherStatelessWidget {
  const _SelectableCounter({
    required this.refCounter,
  });

  final Provided<int> refCounter;

  static final _refBackgroundColor = Computed.withParameter(
    (watch, Provided<int> refCounter) {
      final refCurrentCounter = watch(_refCounterX);
      return refCurrentCounter == refCounter
          ? Colors.green
          : Colors.transparent;
    },
  );

  @override
  Widget build(BuildContext context, BuildStore store) {
    return GestureDetector(
      onTap: () {
        store.read(_refAppStateLogic).setCounterRef(refCounter);
      },
      child: WatcherBuilder(
        builder: (context, store) {
          final backgroundColor = store.watch(_refBackgroundColor(refCounter));

          return ColoredBox(
            color: backgroundColor,
            child: Center(
              child: _Counter(
                refCounter: refCounter,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({
    required this.refCounter,
  });

  final Provided<int> refCounter;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CounterText(
          refCounter: refCounter,
        ),
        const SizedBox(height: 16),
        _CounterIncrementButton(
          refCounter: refCounter,
        ),
      ],
    );
  }
}

class _CounterText extends WatcherStatelessWidget {
  const _CounterText({
    required this.refCounter,
  });

  final Ref<int> refCounter;

  @override
  Widget build(BuildContext context, BuildStore store) {
    return Text(
      '${store.watch(refCounter)}',
      style: Theme.of(context).textTheme.displayLarge!.copyWith(
            color: Colors.black87,
          ),
    );
  }
}

class _CounterIncrementButton extends WatcherStatelessWidget {
  const _CounterIncrementButton({
    required this.refCounter,
  });

  final Provided<int> refCounter;

  @override
  Widget build(BuildContext context, BuildStore store) {
    return ElevatedButton(
      onPressed: () {
        store.read(_refAppStateLogic).incrementCounter(refCounter);
      },
      child: const Icon(Icons.add),
    );
  }
}

class _CurrentCounter extends WatcherStatelessWidget {
  const _CurrentCounter();

  @override
  Widget build(BuildContext context, BuildStore store) {
    return _Counter(
      refCounter: store.watch(_refCounterX),
    );
  }
}
