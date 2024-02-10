import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:state_watcher/src/core/build_store.dart';
import 'package:state_watcher/src/core/refs.dart';
import 'package:state_watcher/src/core/state_observer.dart';
import 'package:state_watcher/src/widgets/state_store.dart';
import 'package:state_watcher/src/widgets/watcher_builder.dart';

void main() {
  group('StateStore', () {
    group('Overrides', () {
      testWidgets('should correctly update overrides', (tester) async {
        final a = Provided<int>.undefined();
        late int va;
        int buildCount = 0;

        final watcher = WatcherBuilder(
          builder: (context, store) {
            buildCount++;
            va = store.watch(a);
            return const SizedBox();
          },
        );

        await tester.pumpWidget(
          StateStore(
            overrides: {a.overrideWithValue(0)},
            child: watcher,
          ),
        );

        expect(va, equals(0));
        expect(buildCount, equals(1));

        await tester.pumpWidget(
          StateStore(
            overrides: {a.overrideWithValue(5)},
            child: watcher,
          ),
        );

        expect(va, equals(5));
        expect(buildCount, equals(2));
      });

      testWidgets('should not rebuild widget if override is the same',
          (tester) async {
        final a = Provided<int>.undefined();
        int buildCount = 0;
        late int va;
        final watcher = WatcherBuilder(
          builder: (context, store) {
            buildCount++;
            va = store.watch(a);
            return const SizedBox();
          },
        );

        await tester.pumpWidget(
          StateStore(
            overrides: {a.overrideWithValue(0)},
            child: watcher,
          ),
        );

        expect(va, equals(0));
        expect(buildCount, equals(1));

        await tester.pumpWidget(
          StateStore(
            overrides: {a.overrideWithValue(0)},
            child: watcher,
          ),
        );

        expect(va, equals(0));
        expect(buildCount, equals(1));
      });

      testWidgets(
          'should not rebuild widget if override is the same but changed in the meantime',
          (tester) async {
        final a = Provided<int>.undefined();
        int buildCount = 0;
        late int va;
        late BuildStore buildStore;
        final watcher = WatcherBuilder(
          builder: (context, store) {
            buildStore = store;
            buildCount++;
            va = store.watch(a);
            return const SizedBox();
          },
        );

        await tester.pumpWidget(
          StateStore(
            overrides: {a.overrideWithValue(0)},
            child: watcher,
          ),
        );

        expect(va, equals(0));
        expect(buildCount, equals(1));

        buildStore.write(a, 4);

        await tester.pump();

        expect(va, equals(4));
        expect(buildCount, equals(2));

        await tester.pumpWidget(
          StateStore(
            overrides: {a.overrideWithValue(0)},
            child: watcher,
          ),
        );

        expect(va, equals(4));
        expect(buildCount, equals(2));
      });

      testWidgets('should correctly remove override', (tester) async {
        final a = Provided<int>.undefined();
        late int va;
        int buildCount = 0;

        final watcher = WatcherBuilder(
          builder: (context, store) {
            buildCount++;
            va = store.watch(a);
            return const SizedBox();
          },
        );

        await tester.pumpWidget(
          StateStore(
            overrides: {a.overrideWithValue(5)},
            child: watcher,
          ),
        );

        expect(va, equals(5));
        expect(buildCount, equals(1));

        await tester.pumpWidget(
          StateStore(
            child: watcher,
          ),
        );

        expect(va, equals(5));
        expect(buildCount, equals(1));
      });
    });

    group('Observers', () {
      testWidgets('should be called when state changes', (tester) async {
        late BuildStore buildStore;
        final watcher = WatcherBuilder(
          builder: (context, store) {
            buildStore = store;
            store.watch(a);
            return const SizedBox();
          },
        );
        final obs = _StateObserver();
        await tester.pumpWidget(
          StateStore(
            observers: [obs],
            child: watcher,
          ),
        );

        buildStore.write(a, 5);
        await tester.pump();
        expect(obs.logs, [
          'didStateCreated ${a.debugName} with 0',
          'didStateUpdated ${a.debugName} from 0 to 5',
        ]);
      });

      testWidgets('should correcly update observers', (tester) async {
        late BuildStore buildStore;
        final watcher = WatcherBuilder(
          builder: (context, store) {
            buildStore = store;
            store.watch(a);
            return const SizedBox();
          },
        );
        final obs1 = _StateObserver();
        final obs2 = _StateObserver();
        await tester.pumpWidget(
          StateStore(
            observers: [obs1],
            child: watcher,
          ),
        );

        buildStore.write(a, 5);
        await tester.pump();
        expect(obs1.logs, [
          'didStateCreated ${a.debugName} with 0',
          'didStateUpdated ${a.debugName} from 0 to 5',
        ]);
        expect(obs2.logs, isEmpty);

        await tester.pumpWidget(
          StateStore(
            observers: [obs2],
            child: watcher,
          ),
        );

        buildStore.write(a, 6);
        await tester.pump();

        expect(obs1.logs, [
          'didStateCreated ${a.debugName} with 0',
          'didStateUpdated ${a.debugName} from 0 to 5',
        ]);
        expect(obs2.logs, [
          'didStateUpdated ${a.debugName} from 5 to 6',
        ]);
      });
    });

    group('Lifecycle', () {
      testWidgets('should correctly delete refs', (tester) async {
        final a = Provided((_) => 0);
        final c = Computed((watch) {
          return watch(a) * 2;
        });

        await tester.pumpWidget(
          StateStore(
            child: StateStore(
              child: StateStore(
                overrides: {
                  a.overrideWithValue(5),
                },
                child: WatcherBuilder(
                  builder: (context, store) {
                    store.watch(c);
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        );

        // Removing the last store should delete all refs without exception.
        await tester.pumpWidget(
          const StateStore(
            child: StateStore(
              child: SizedBox(),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
      });
    });
  });
}

final a = Provided((_) => 0);

class _StateObserver extends StateObserver {
  final logs = <String>[];

  @override
  void didStateCreated<T>(Ref<T> ref, T value) {
    if (ref.id != a.id) {
      return;
    }
    logs.add('didStateCreated ${ref.debugName} with $value');
  }

  @override
  void didStateUpdated<T>(Ref<T> ref, T oldValue, T newValue) {
    if (ref.id != a.id) {
      return;
    }
    logs.add('didStateUpdated ${ref.debugName} from $oldValue to $newValue');
  }

  @override
  void didStateDeleted<T>(Ref<T> ref) {
    if (ref.id != a.id) {
      return;
    }
    logs.add('didStateDeleted ${ref.debugName}');
  }

  void reset() {
    logs.clear();
  }
}
