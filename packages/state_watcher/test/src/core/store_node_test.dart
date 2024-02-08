import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:state_watcher/src/core/refs.dart';

void main() {
  group('Store', () {
    group('[Provided]', () {
      test('should be able to be read', () {
        final store = StoreNode();
        final a = Provided((_) => 4);
        final va = store.read(a);

        expect(va, equals(4));
      });

      test('should be able to be written', () {
        final store = StoreNode();
        final a = Provided((_) => 4);
        store.write(a, 8);
        final va = store.read(a);

        expect(va, equals(8));
      });

      test('should always be created in the highest store', () {
        final store1 = StoreNode();
        final store2 = StoreNode(parent: store1);
        final a = Provided((_) => 4);

        expect(store2.read(a), equals(4));
        store1.write(a, 5);
        expect(store2.read(a), equals(5));
      });

      test('undefined() should throws if read', () {
        final refProvided = Provided<int>.undefined();
        final store = StoreNode();
        expect(() => store.read(refProvided), throwsStateError);
      });

      test('can be overriden with a value', () {
        final a = Provided((_) => 4);
        final store = StoreNode(overrides: {a.overrideWithValue(3)});
        final va = store.read(a);
        expect(va, 3);
      });

      test('can be overriden with a function', () {
        final a = Provided((_) => 4);
        final store = StoreNode(overrides: {a.overrideWith((_) => 3)});
        final va = store.read(a);
        expect(va, 3);
      });

      test('should add a dependency with read but not watch it', () {
        final a = Provided((_) => 4, autoDispose: true);
        final b = Provided((read) => read(a) * 2);
        final store = StoreNode();
        expect(store.read(b), 8);
        store.write(a, 5);
        expect(store.read(b), 8);
        store.delete(b);
        expect(store.hasStateFor(a), false);
        expect(store.hasStateFor(b), false);
      });
    });

    group('[Computed]', () {
      group('should be able to be read when', () {
        test('independent', () {
          final store = StoreNode();
          final b = Computed((watch) => 2);
          final vb = store.read(b);

          expect(vb, equals(2));
        });

        test('depends on Provided', () {
          final store = StoreNode();
          final a = Provided((_) => 4);
          final b = Computed((watch) => watch(a) * 2);
          final vb = store.read(b);

          expect(vb, equals(8));
        });

        test('depends on another Computed', () {
          final store = StoreNode();
          final a = Provided((_) => 4);
          final b = Computed((watch) => watch(a) * 2);
          final c = Computed((watch) => watch(b) * 2);
          final vc = store.read(c);

          expect(vc, equals(16));
        });
      });

      group('should not be able to depends on', () {
        test('itself', () {
          final store = StoreNode();
          late final Computed<int> b;
          b = Computed((watch) => watch(b) * 2);

          expect(
            () => store.read(b),
            throwsA(isA<CircularDependencyError>()),
          );
        });

        test('a dependent', () {
          final store = StoreNode();
          late final Computed<int> b;
          late final Computed<int> c;
          b = Computed((watch) => watch(c) * 2);
          c = Computed((watch) => watch(b) * 2);

          expect(
            () => store.read(b),
            throwsA(isA<CircularDependencyError>()),
          );
        });
      });

      group('[Creation]', () {
        test('should be created in the lowest store if not global', () {
          final a = Provided((_) => 4);
          final store1 = StoreNode();
          final store2 = StoreNode(
            parent: store1,
            overrides: {a.overrideWithValue(3)},
          );
          final c = Computed((watch) => watch(a) * 2);

          expect(store1.read(a), equals(4));
          expect(store2.read(c), equals(6));
          expect(store2.read(a), equals(3));
          store1.write(a, 5);
          expect(store1.read(a), equals(5));
          expect(store2.read(c), equals(6));
          expect(store2.read(a), equals(3));
          store2.write(a, 5);
          expect(store1.read(a), equals(5));
          expect(store2.read(c), equals(10));
          expect(store2.read(a), equals(5));
        });

        test('should be created in the root store if global', () {
          final a = Provided((_) => 4);
          final store1 = StoreNode();
          final store2 = StoreNode(
            parent: store1,
            overrides: {a.overrideWithValue(3)},
          );
          final c = Computed((watch) => watch(a) * 2, global: true);

          expect(store1.read(a), equals(4));
          expect(store2.read(c), equals(8));
          expect(store2.read(a), equals(3));
          store1.write(a, 5);
          expect(store1.read(a), equals(5));
          expect(store2.read(c), equals(10));
          expect(store2.read(a), equals(3));
          store2.write(a, 5);
          expect(store1.read(a), equals(5));
          expect(store2.read(c), equals(10));
          expect(store2.read(a), equals(5));
        });
      });

      group('withParameter', () {
        test('with same parameter should have same id', () {
          final a = Provided((_) => 4);
          final b = Computed.withParameter((watch, int x) {
            return watch(a) * x;
          });

          final c1 = b(2);
          final c2 = b(3);
          final c3 = b(2);

          expect(c1.id == c2.id, isFalse);
          expect(c1.id == c3.id, isTrue);
        });

        test('with same parameter should have same id', () {
          final a = Provided((_) => 4);
          final b = Computed.withParameter((watch, int x) {
            return watch(a) * x;
          });

          final c1 = b(2);
          final c2 = b(3);
          final c3 = b(2);

          expect(c1.id == c2.id, isFalse);
          expect(c1.id == c3.id, isTrue);
        });
      });
    });

    group('[Observed]', () {
      test('should be able to watch', () {
        final store = StoreNode();
        int count = 0;
        final o = Observed(() {
          count++;
        });
        final a = Provided((_) => 4);
        store.watch(o, a);
        expect(count, 0);
        store.write(a, 5);
        expect(count, 1);
        store.write(a, 5);
        expect(count, 1);
      });
    });

    group('[Delete]', () {
      test('Should remove a node from its dependencies', () {
        final logs1 = <int>[];
        final v1 = Provided((_) => 4);
        final c1 = Computed((watch) {
          final result = watch(v1) * 2;
          logs1.add(result);
          return result;
        });

        final store = StoreNode();

        // creates v1 -> c1.
        store.read(c1);
        expect(logs1, [8]);

        // updates v1, which should update c1.
        store.update(v1, (x) => x + 1);
        expect(logs1, [8, 10]);

        // c1 should no longer exists.
        store.delete(c1);

        // since c1 no longer exists, it should not be updated.
        store.update(v1, (x) => x + 1);
        expect(logs1, [8, 10]);
      });

      test('Should remove a chain of nodes', () {
        const v = 4;
        final v1 = Provided((_) => v);

        final allLogs = <List<int>>[];
        final cx = <Computed<int>>[];

        Ref<int> dependency = v1;

        const max = 10;

        for (int i = 0; i < max; i++) {
          final logs = <int>[];
          allLogs.add(logs);
          final dep = dependency;
          final c = Computed((watch) {
            final result = watch(dep) * 2;
            logs.add(result);
            return result;
          });
          cx.add(c);
          dependency = c;
        }

        final store = StoreNode();
        // Creates v1 -> c0 -> ... -> c9.
        store.read(cx.last);

        for (int i = 0; i < max; i++) {
          final mult = math.pow(2, i + 1);
          expect(allLogs[i], [v * mult]);
        }

        // updates v1, which should update cO through c9.
        store.update(v1, (x) => x + 1);
        for (int i = 0; i < max; i++) {
          final mult = math.pow(2, i + 1);
          expect(allLogs[i], [v * mult, (v + 1) * mult]);
        }

        // c9 should no longer exists and all the chain should also be deleted.
        store.delete(cx.last);

        // since all the chain is deleted, they should not be updated.
        store.update(v1, (x) => x + 1);
        for (int i = 0; i < max; i++) {
          final mult = math.pow(2, i + 1);
          expect(allLogs[i], [v * mult, (v + 1) * mult]);
        }
      });

      test('Should remove a chain of nodes across stores', () {
        const v = 4;
        final v1 = Provided((_) => v);

        final allLogs = <List<int>>[];
        final cx = <Computed<int>>[];

        Ref<int> dependency = v1;

        const max = 3;

        for (int i = 0; i < max; i++) {
          final logs = <int>[];
          allLogs.add(logs);
          final dep = dependency;
          final c = Computed((watch) {
            final result = watch(dep) * 2;
            logs.add(result);
            return result;
          });
          cx.add(c);
          dependency = c;
        }

        final c1 = cx[0];
        final c2 = cx[1];
        final c3 = cx[2];

        final store1 = StoreNode();
        final store2 = StoreNode(parent: store1);
        final store3 = StoreNode(parent: store2);
        final store4 = StoreNode(parent: store3);

        store4.read(v1);
        store4.read(c1);
        store4.read(c2);
        store4.read(c3);

        for (int i = 0; i < max; i++) {
          final mult = math.pow(2, i + 1);
          expect(allLogs[i], [v * mult]);
        }

        // updates v1, which should update c1 through c3.
        store1.update(v1, (x) => x + 1);
        for (int i = 0; i < max; i++) {
          final mult = math.pow(2, i + 1);
          expect(allLogs[i], [v * mult, (v + 1) * mult]);
        }

        // c3 should no longer exists and all the chain should also be deleted.
        store4.delete(c3);

        // since all the chain is deleted, they should not be updated.
        store1.update(v1, (x) => x + 1);
        for (int i = 0; i < max; i++) {
          final mult = math.pow(2, i + 1);
          expect(allLogs[i], [v * mult, (v + 1) * mult]);
        }
      });

      test('Should not be able to delete a node that has dependents', () {
        final v = Provided((_) => 3);
        final c = Computed((watch) => watch(v));
        final store = StoreNode();
        store.read(c);
        expect(() => store.delete(v), throwsA(isA<NodeHasDependentsError>()));
      });
    });

    group('[Dispose]', () {
      test('Should not be able to dispose a store with dependents', () {
        final store1 = StoreNode()..init();
        // ignore: unused_local_variable
        final store2 = StoreNode(parent: store1)..init();

        expect(() => store1.dispose(), throwsA(isA<StoreHasDependentsError>()));
      });
    });

    group('[AutoDispose]', () {
      test('should dispose a Provided which was read by a deleted node', () {
        final store = StoreNode();
        final a = Provided((_) => 4, autoDispose: true);
        final b = Provided((read) {
          read(a);
          return 5;
        });
        store.delete(b);
        expect(store.hasStateFor(a), false);
      });
    });
  });
}
