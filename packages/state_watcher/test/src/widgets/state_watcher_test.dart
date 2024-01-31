import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:state_watcher/src/core/refs.dart';
import 'package:state_watcher/src/widgets/build_scope.dart';
import 'package:state_watcher/src/widgets/state_scope.dart';
import 'package:state_watcher/src/widgets/state_watcher.dart';
import 'package:state_watcher/src/widgets/watcher_stateful_widget.dart';

void main() {
  group('Watcher', () {
    group('watch', () {
      testWidgets(
        'should throw without a StateScope ancestor',
        (tester) async {
          final a = Variable((_) => 0);
          final tree = StateWatcher(
            builder: (context, scope) {
              scope.watch(a);
              return const SizedBox();
            },
          );
          await tester.pumpWidget(tree);
          expect(tester.takeException(), isA<FlutterError>());
        },
      );
      testWidgets(
        'should not throw with a StateScope ancestor',
        (tester) async {
          final a = Variable((_) => 0);
          final tree = StateScope(
            child: StateWatcher(
              builder: (context, scope) {
                scope.watch(a);
                return const SizedBox();
              },
            ),
          );
          await tester.pumpWidget(tree);
          expect(tester.takeException(), isNull);
        },
      );
    });
    group('should be rebuilt only when', () {
      testWidgets('variable changed', (tester) async {
        final a = Variable((_) => 0);
        int buildCount = 0;
        late BuildScope buildScope;
        final tree = StateScope(
          child: StateWatcher(
            builder: (context, scope) {
              buildScope = scope;
              buildCount++;
              scope.watch(a);
              return const SizedBox();
            },
          ),
        );
        await tester.pumpWidget(tree);
        expect(buildCount, equals(1));
        buildScope.write(a, 5);
        await tester.pump();
        expect(buildCount, equals(2));
        buildScope.write(a, 5);
        await tester.pump();
        expect(buildCount, equals(2));
      });

      testWidgets('computed changed', (tester) async {
        final a = Variable((_) => 0);
        final c = Computed((watch) {
          return watch(a).isEven;
        });
        int buildCount = 0;
        late BuildScope buildScope;
        final tree = StateScope(
          child: StateWatcher(
            builder: (context, scope) {
              buildScope = scope;
              buildCount++;
              scope.watch(c);
              return const SizedBox();
            },
          ),
        );
        await tester.pumpWidget(tree);
        expect(buildCount, equals(1));
        buildScope.write(a, 5);
        await tester.pump();
        expect(buildCount, equals(2));
        buildScope.write(a, 7);
        await tester.pump();
        expect(buildCount, equals(2));
      });

      group('computed with parameter changed', () {
        testWidgets('because of watched', (tester) async {
          late BuildScope buildScope;
          final logs = <int>[];
          final tree = StateScope(
            child: StateWatcher(
              builder: (context, scope) {
                buildScope = scope;
                return _Watcher(
                  add: 1,
                  logs: logs,
                );
              },
            ),
          );
          expect(logs, isEmpty);
          await tester.pumpWidget(tree);
          expect(logs, equals([5]));
          buildScope.write(_refVar, 5);
          await tester.pump();
          expect(logs, equals([5, 6]));
        });

        testWidgets('because of parameter', (tester) async {
          final a = Variable((_) => 1);
          late BuildScope buildScope;
          final logs = <int>[];
          final tree = StateScope(
            child: StateWatcher(
              builder: (context, scope) {
                buildScope = scope;
                return _Watcher(
                  add: scope.watch(a),
                  logs: logs,
                );
              },
            ),
          );
          expect(logs, isEmpty);
          await tester.pumpWidget(tree);
          expect(logs, equals([5]));
          buildScope.write(a, 2);
          await tester.pump();
          expect(logs, equals([5, 6]));
        });
      });

      testWidgets('computed with parameter correctly deleted', (tester) async {
        final a = Variable((_) => 1);
        late BuildScope buildScope;
        final logs = <int>[];
        final tree = StateScope(
          child: StateWatcher(
            builder: (context, scope) {
              buildScope = scope;
              return _Watcher(
                add: scope.watch(a),
                logs: logs,
              );
            },
          ),
        );
        await tester.pumpWidget(tree);
        expect(buildScope.hasStateFor(_computedWithParam(1)), isTrue);
        expect(buildScope.hasStateFor(_computedWithParam(2)), isFalse);
        buildScope.write(a, 2);
        await tester.pump();
        expect(buildScope.hasStateFor(_computedWithParam(1)), isFalse);
        expect(buildScope.hasStateFor(_computedWithParam(2)), isTrue);
      });
    });

    group('read', () {
      testWidgets('should throw if used when building', (tester) async {
        final a = Variable((_) => 0);
        final tree = StateScope(
          child: StateWatcher(
            builder: (context, scope) {
              scope.read(a);
              return const SizedBox();
            },
          ),
        );
        await tester.pumpWidget(tree);
        expect(tester.takeException(), isA<AssertionError>());
      });

      testWidgets('should not throw if used in a callback ', (tester) async {
        final a = Variable((_) => 0);
        final tree = StateScope(
          child: StateWatcher(
            builder: (context, scope) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  scope.read(a);
                },
                child: const SizedBox.expand(),
              );
            },
          ),
        );
        await tester.pumpWidget(tree);
        await tester.tap(find.byType(GestureDetector));
        expect(tester.takeException(), isNull);
      });
    });
    group('write', () {
      testWidgets('should throw if used when building', (tester) async {
        final a = Variable((_) => 0);
        final tree = StateScope(
          child: StateWatcher(
            builder: (context, scope) {
              scope.write(a, 5);
              return const SizedBox();
            },
          ),
        );
        await tester.pumpWidget(tree);
        expect(tester.takeException(), isA<AssertionError>());
      });

      testWidgets('should not throw if used in a callback ', (tester) async {
        final a = Variable((_) => 0);
        final tree = StateScope(
          child: StateWatcher(
            builder: (context, scope) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  scope.write(a, 5);
                },
                child: const SizedBox.expand(),
              );
            },
          ),
        );
        await tester.pumpWidget(tree);
        await tester.tap(find.byType(GestureDetector));
        expect(tester.takeException(), isNull);
      });
    });
    group('update', () {
      testWidgets('should throw if used when building', (tester) async {
        final a = Variable((_) => 0);
        final tree = StateScope(
          child: StateWatcher(
            builder: (context, scope) {
              scope.update(a, (x) => x + 1);
              return const SizedBox();
            },
          ),
        );
        await tester.pumpWidget(tree);
        expect(tester.takeException(), isA<AssertionError>());
      });

      testWidgets('should not throw if used in a callback ', (tester) async {
        final a = Variable((_) => 0);
        final tree = StateScope(
          child: StateWatcher(
            builder: (context, scope) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  scope.update(a, (x) => x + 1);
                },
                child: const SizedBox.expand(),
              );
            },
          ),
        );
        await tester.pumpWidget(tree);
        await tester.tap(find.byType(GestureDetector));
        expect(tester.takeException(), isNull);
      });
    });
    group('delete', () {
      testWidgets('should throw if used when building', (tester) async {
        final a = Variable((_) => 0);
        final tree = StateScope(
          child: StateWatcher(
            builder: (context, scope) {
              scope.delete(a);
              return const SizedBox();
            },
          ),
        );
        await tester.pumpWidget(tree);
        expect(tester.takeException(), isA<AssertionError>());
      });

      testWidgets('should not throw if used in a callback ', (tester) async {
        final a = Variable((_) => 0);
        final tree = StateScope(
          child: StateWatcher(
            builder: (context, scope) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  scope.delete(a);
                },
                child: const SizedBox.expand(),
              );
            },
          ),
        );
        await tester.pumpWidget(tree);
        await tester.tap(find.byType(GestureDetector));
        expect(tester.takeException(), isNull);
      });
    });
  });
}

final _refVar = Variable((_) => 4);
final _computedWithParam = Computed.withParameter((watch, int parameter) {
  return watch(_refVar) + parameter;
});

class _Watcher extends WatcherStatefulWidget {
  const _Watcher({
    required this.add,
    required this.logs,
  });

  final int add;
  final List<int> logs;

  @override
  State<_Watcher> createState() => __WatcherState();
}

class __WatcherState extends State<_Watcher> {
  @override
  Widget build(BuildContext context) {
    final sum = scope.watch(_computedWithParam(widget.add));
    widget.logs.add(sum);
    return const SizedBox();
  }
}
