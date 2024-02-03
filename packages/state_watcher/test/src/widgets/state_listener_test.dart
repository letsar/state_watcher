import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:state_watcher/src/core/refs.dart';
import 'package:state_watcher/src/widgets/build_store.dart';
import 'package:state_watcher/src/widgets/state_store.dart';
import 'package:state_watcher/src/widgets/watcher_builder.dart';
import 'package:state_watcher/src/widgets/watcher_effect.dart';

void main() {
  group('WatcherEffect', () {
    testWidgets('should immediately call onStateChanged when state changes',
        (tester) async {
      final a = Variable((_) => 4);
      final logs = <String>[];
      late BuildStore buildStore;
      final tree = StateStore(
        child: WatcherBuilder(
          builder: (BuildContext context, BuildStore store) {
            buildStore = store;
            return WatcherEffect(
              ref: a,
              onStateChanged: (context, oldValue, newValue) {
                logs.add('$oldValue=>$newValue');
              },
              child: const SizedBox(),
            );
          },
        ),
      );

      await tester.pumpWidget(tree);
      expect(logs, isEmpty);

      buildStore.write(a, 5);
      expect(logs, ['4=>5']);
    });

    testWidgets('should not rebuild when state changes', (tester) async {
      final a = Variable((_) => 4);
      final logs = <String>[];
      late BuildStore buildStore;
      final tree = StateStore(
        child: WatcherBuilder(
          builder: (BuildContext context, BuildStore store) {
            buildStore = store;
            return WatcherEffect(
              ref: a,
              onStateChanged: (context, oldValue, newValue) {
                logs.add('$oldValue=>$newValue');
              },
              child: Builder(
                builder: (context) {
                  logs.add('Builder');
                  return const SizedBox();
                },
              ),
            );
          },
        ),
      );

      await tester.pumpWidget(tree);
      expect(logs, ['Builder']);

      buildStore.write(a, 5);
      expect(logs, ['Builder', '4=>5']);

      await tester.pumpWidget(tree);
      expect(logs, ['Builder', '4=>5']);
    });

    testWidgets('should be able to change the ref', (tester) async {
      final a = Variable((_) => 4);
      final b = Variable((_) => 0);
      final logs = <String>[];
      late BuildStore buildStore;
      await tester.pumpWidget(
        StateStore(
          key: const ValueKey(1),
          child: WatcherBuilder(
            key: const ValueKey(2),
            builder: (BuildContext context, BuildStore store) {
              buildStore = store;
              return WatcherEffect(
                key: const ValueKey(3),
                ref: a,
                onStateChanged: (context, oldValue, newValue) {
                  logs.add('$oldValue=>$newValue');
                },
                child: Builder(
                  builder: (context) {
                    logs.add('Builder');
                    return const SizedBox();
                  },
                ),
              );
            },
          ),
        ),
      );

      expect(logs, ['Builder']);

      buildStore.write(a, 5);
      expect(logs, ['Builder', '4=>5']);

      await tester.pumpWidget(
        StateStore(
          key: const ValueKey(1),
          child: WatcherBuilder(
            key: const ValueKey(2),
            builder: (BuildContext context, BuildStore store) {
              buildStore = store;
              return WatcherEffect(
                key: const ValueKey(3),
                ref: b,
                onStateChanged: (context, oldValue, newValue) {
                  logs.add('$oldValue=>$newValue');
                },
                child: Builder(
                  builder: (context) {
                    logs.add('Builder');
                    return const SizedBox();
                  },
                ),
              );
            },
          ),
        ),
      );
      expect(logs, ['Builder', '4=>5', 'Builder']);
      buildStore.write(a, 7);
      expect(logs, ['Builder', '4=>5', 'Builder']);
      buildStore.write(b, 8);
      expect(logs, ['Builder', '4=>5', 'Builder', '0=>8']);
    });
  });
}
