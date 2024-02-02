import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:state_watcher/src/core/refs.dart';
import 'package:state_watcher/src/widgets/build_store.dart';
import 'package:state_watcher/src/widgets/state_listener.dart';
import 'package:state_watcher/src/widgets/state_store.dart';
import 'package:state_watcher/src/widgets/watcher_builder.dart';

void main() {
  group('StateListener', () {
    testWidgets('should immediately call onStateChanged when state changes',
        (tester) async {
      final a = Variable((_) => 4);
      final logs = <String>[];
      late BuildStore buildStore;
      final tree = StateStore(
        child: WatcherBuilder(
          builder: (BuildContext context, BuildStore store) {
            buildStore = store;
            return StateListener(
              ref: a,
              onStateChanged: (context, oldValue, newValue) {
                logs.add('old: $oldValue, new: $newValue');
              },
              child: const SizedBox(),
            );
          },
        ),
      );

      await tester.pumpWidget(tree);
      expect(logs, isEmpty);

      buildStore.write(a, 5);
      expect(logs, ['old: 4, new: 5']);
    });

    testWidgets('should not rebuild when state changes', (tester) async {
      final a = Variable((_) => 4);
      final logs = <String>[];
      late BuildStore buildStore;
      final tree = StateStore(
        child: WatcherBuilder(
          builder: (BuildContext context, BuildStore store) {
            buildStore = store;
            return StateListener(
              ref: a,
              onStateChanged: (context, oldValue, newValue) {
                logs.add('old: $oldValue, new: $newValue');
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
      expect(logs, ['Builder', 'old: 4, new: 5']);

      await tester.pumpWidget(tree);
      expect(logs, ['Builder', 'old: 4, new: 5']);
    });
  });
}
