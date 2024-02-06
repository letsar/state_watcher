import 'package:examples/timers/home/home_screen_logic.dart';
import 'package:examples/timers/home/timer_logic.dart';
import 'package:examples/timers/models/expirable.dart';
import 'package:flutter/material.dart';
import 'package:state_watcher/state_watcher.dart';

final _refCurrentExpirable = Provided<Expirable>.undefined();
final _refCurrentExpirationDate = Computed((watch) {
  return watch(_refCurrentExpirable).expirationDate;
});

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: ExpirableListView()),
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
        return StateStore(
          overrides: {
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

  static final computedDurationLeftByExpirationDate = Computed.withParameter(
    (watch, DateTime parameter) {
      final timerLogic = watch(refTimerLogic);
      final currentDate = watch(timerLogic.refCurrentDate);
      final duration = parameter.difference(currentDate);
      if (duration.inSeconds < 1) {
        return 'Expired';
      }
      final seconds = duration.inSeconds;
      return switch (seconds) {
        >= 60 => '${seconds ~/ 60}mn',
        _ => '${seconds}s',
      };
    },
  );

  @override
  Widget build(BuildContext context, BuildStore store) {
    final expirationDate = store.watch(_refCurrentExpirationDate);
    final expiration = store.watch(
      computedDurationLeftByExpirationDate(expirationDate),
    );

    return ListTile(
      title: Text(expiration),
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