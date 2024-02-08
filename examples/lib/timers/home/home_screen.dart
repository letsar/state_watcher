import 'package:examples/timers/home/home_screen_logic.dart';
import 'package:examples/timers/home/timer_logic.dart';
import 'package:examples/timers/models/expirable.dart';
import 'package:flutter/material.dart';
import 'package:state_watcher/state_watcher.dart';

/// Providing a different [Expirable] for each [ExpirableTile].
final _refCurrentExpirable = Provided<Expirable>.undefined();

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

    final seconds = duration.inSeconds;
    return switch (seconds) {
      >= 60 => '${seconds ~/ 60}mn',
      _ => '${seconds}s',
    };
  },
  debugName: 'currentDurationLeft',
  global: true,
);

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: ExpirableListView(),
      ),
      floatingActionButton: _AddExpirableButton(),
    );
  }
}

class ExpirableListView extends WatcherStatelessWidget {
  const ExpirableListView({
    super.key,
  });

  @override
  Widget build(BuildContext context, BuildStore store) {
    final expirables = store.watch(refExpirables);

    return ListView.builder(
      itemCount: expirables.length,
      itemBuilder: (context, index) {
        final expirable = expirables[index];

        // We create another store to provide a different [Expirable] for each
        // [ExpirableTile].
        return StateStore(
          overrides: {
            // When reading _refCurrentExpirable in the subtree, we will get
            // [expirable].
            _refCurrentExpirable.overrideWithValue(expirable),
          },
          child: ExpirableTile(
            key: ValueKey(expirable.id),
          ),
        );
      },
    );
  }
}

class ExpirableTile extends WatcherStatelessWidget {
  const ExpirableTile({
    super.key,
  });

  @override
  Widget build(BuildContext context, BuildStore store) {
    final expirable = store.watch(_refCurrentExpirable);
    final durationLeft = store.watch(
      _refCurrentDurationLeft(expirable.expirationDate),
    );

    return ListTile(
      title: Text(durationLeft),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          final id = store.read(_refCurrentExpirable).id;
          store.read(refHomeScreenLogic).removeExpirable(id);
        },
      ),
    );
  }
}

class _AddExpirableButton extends WatcherStatelessWidget {
  const _AddExpirableButton();

  @override
  Widget build(BuildContext context, BuildStore store) {
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () {
        store.read(refHomeScreenLogic).addExpirable();
      },
    );
  }
}
