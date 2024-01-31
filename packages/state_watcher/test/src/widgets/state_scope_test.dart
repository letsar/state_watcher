import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:state_watcher/src/core/refs.dart';
import 'package:state_watcher/src/core/state_observer.dart';
import 'package:state_watcher/src/widgets/build_scope.dart';
import 'package:state_watcher/src/widgets/state_scope.dart';
import 'package:state_watcher/src/widgets/state_watcher.dart';

void main() {
  group('StateScope', () {
    group('Overrides', () {
      testWidgets('should correctly update overrides', (tester) async {
        final a = Variable<int>.undefined();
        late int va;
        int buildCount = 0;

        final watcher = StateWatcher(
          builder: (context, scope) {
            buildCount++;
            va = scope.watch(a);
            return const SizedBox();
          },
        );

        await tester.pumpWidget(
          StateScope(
            overrides: {a.overrideWithValue(0)},
            child: watcher,
          ),
        );

        expect(va, equals(0));
        expect(buildCount, equals(1));

        await tester.pumpWidget(
          StateScope(
            overrides: {a.overrideWithValue(5)},
            child: watcher,
          ),
        );

        expect(va, equals(5));
        expect(buildCount, equals(2));
      });

      testWidgets('should not rebuild widget if override is the same',
          (tester) async {
        final a = Variable<int>.undefined();
        int buildCount = 0;
        late int va;
        final watcher = StateWatcher(
          builder: (context, scope) {
            buildCount++;
            va = scope.watch(a);
            return const SizedBox();
          },
        );

        await tester.pumpWidget(
          StateScope(
            overrides: {a.overrideWithValue(0)},
            child: watcher,
          ),
        );

        expect(va, equals(0));
        expect(buildCount, equals(1));

        await tester.pumpWidget(
          StateScope(
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
        final a = Variable<int>.undefined();
        int buildCount = 0;
        late int va;
        late BuildScope buildScope;
        final watcher = StateWatcher(
          builder: (context, scope) {
            buildScope = scope;
            buildCount++;
            va = scope.watch(a);
            return const SizedBox();
          },
        );

        await tester.pumpWidget(
          StateScope(
            overrides: {a.overrideWithValue(0)},
            child: watcher,
          ),
        );

        expect(va, equals(0));
        expect(buildCount, equals(1));

        buildScope.write(a, 4);

        await tester.pump();

        expect(va, equals(4));
        expect(buildCount, equals(2));

        await tester.pumpWidget(
          StateScope(
            overrides: {a.overrideWithValue(0)},
            child: watcher,
          ),
        );

        expect(va, equals(4));
        expect(buildCount, equals(2));
      });

      testWidgets('should correctly remove override', (tester) async {
        final a = Variable<int>.undefined();
        late int va;
        int buildCount = 0;

        final watcher = StateWatcher(
          builder: (context, scope) {
            buildCount++;
            va = scope.watch(a);
            return const SizedBox();
          },
        );

        await tester.pumpWidget(
          StateScope(
            overrides: {a.overrideWithValue(5)},
            child: watcher,
          ),
        );

        expect(va, equals(5));
        expect(buildCount, equals(1));

        await tester.pumpWidget(
          StateScope(
            child: watcher,
          ),
        );

        expect(va, equals(5));
        expect(buildCount, equals(1));
      });
    });

    group('Observers', () {
      testWidgets('should be called when state changes', (tester) async {
        late BuildScope buildScope;
        final watcher = StateWatcher(
          builder: (context, scope) {
            buildScope = scope;
            scope.watch(a);
            return const SizedBox();
          },
        );
        final obs = _StateObserver();
        await tester.pumpWidget(
          StateScope(
            observers: [obs],
            child: watcher,
          ),
        );

        buildScope.write(a, 5);
        await tester.pump();
        expect(obs.logs, [
          'didStateCreated ${a.debugName} with 0',
          'didStateUpdated ${a.debugName} from 0 to 5',
        ]);
      });

      testWidgets('should correcly update observers', (tester) async {
        late BuildScope buildScope;
        final watcher = StateWatcher(
          builder: (context, scope) {
            buildScope = scope;
            scope.watch(a);
            return const SizedBox();
          },
        );
        final obs1 = _StateObserver();
        final obs2 = _StateObserver();
        await tester.pumpWidget(
          StateScope(
            observers: [obs1],
            child: watcher,
          ),
        );

        buildScope.write(a, 5);
        await tester.pump();
        expect(obs1.logs, [
          'didStateCreated ${a.debugName} with 0',
          'didStateUpdated ${a.debugName} from 0 to 5',
        ]);
        expect(obs2.logs, isEmpty);

        await tester.pumpWidget(
          StateScope(
            observers: [obs2],
            child: watcher,
          ),
        );

        buildScope.write(a, 6);
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
        final a = Variable((_) => 0);
        final c = Computed((watch) {
          return watch(a) * 2;
        });

        await tester.pumpWidget(
          StateScope(
            child: StateScope(
              child: StateScope(
                overrides: {
                  a.overrideWithValue(5),
                },
                child: StateWatcher(
                  builder: (context, scope) {
                    scope.watch(c);
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        );

        // Removing the last scope should delete all refs without exception.
        await tester.pumpWidget(
          const StateScope(
            child: StateScope(
              child: SizedBox(),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
      });
    });
  });
}

final a = Variable((_) => 0);

class _StateObserver extends StateObserver {
  final logs = <String>[];

  @override
  void didStateCreated<T>(Scope scope, Ref<T> ref, T value) {
    if (ref.id != a.id) {
      return;
    }
    logs.add('didStateCreated ${ref.debugName} with $value');
  }

  @override
  void didStateUpdated<T>(Scope scope, Ref<T> ref, T oldValue, T newValue) {
    if (ref.id != a.id) {
      return;
    }
    logs.add('didStateUpdated ${ref.debugName} from $oldValue to $newValue');
  }

  @override
  void didStateDeleted<T>(Scope scope, Ref<T> ref) {
    if (ref.id != a.id) {
      return;
    }
    logs.add('didStateDeleted ${ref.debugName}');
  }

  void reset() {
    logs.clear();
  }
}
