import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:state_watcher/src/core/refs.dart';

void main() {
  group('Scope', () {
    group('[Variable]', () {
      test('should be able to be read', () {
        final scope = ScopeContext();
        final a = Variable((_) => 4);
        final va = scope.read(a);

        expect(va, equals(4));
      });

      test('should be able to be written', () {
        final scope = ScopeContext();
        final a = Variable((_) => 4);
        scope.write(a, 8);
        final va = scope.read(a);

        expect(va, equals(8));
      });

      test('should always be created in the highest scope', () {
        final scope1 = ScopeContext();
        final scope2 = ScopeContext(parent: scope1);
        final a = Variable((_) => 4);

        expect(scope2.read(a), equals(4));
        scope1.write(a, 5);
        expect(scope2.read(a), equals(5));
      });

      test('undefined() should throws if read', () {
        final refVariable = Variable<int>.undefined();
        final scope = ScopeContext();
        expect(() => scope.read(refVariable), throwsStateError);
      });

      test('can be overriden with a value', () {
        final a = Variable((_) => 4);
        final scope = ScopeContext(overrides: {a.overrideWithValue(3)});
        final va = scope.read(a);
        expect(va, 3);
      });

      test('can be overriden with a function', () {
        final a = Variable((_) => 4);
        final scope = ScopeContext(overrides: {a.overrideWith((_) => 3)});
        final va = scope.read(a);
        expect(va, 3);
      });
    });

    group('[Computed]', () {
      group('should be able to be read when', () {
        test('independent', () {
          final scope = ScopeContext();
          final b = Computed((watch) => 2);
          final vb = scope.read(b);

          expect(vb, equals(2));
        });

        test('depends on Variable', () {
          final scope = ScopeContext();
          final a = Variable((_) => 4);
          final b = Computed((watch) => watch(a) * 2);
          final vb = scope.read(b);

          expect(vb, equals(8));
        });

        test('depends on another Computed', () {
          final scope = ScopeContext();
          final a = Variable((_) => 4);
          final b = Computed((watch) => watch(a) * 2);
          final c = Computed((watch) => watch(b) * 2);
          final vc = scope.read(c);

          expect(vc, equals(16));
        });
      });

      group('should not be able to depends on', () {
        test('itself', () {
          final scope = ScopeContext();
          late final Computed<int> b;
          b = Computed((watch) => watch(b) * 2);

          expect(
            () => scope.read(b),
            throwsA(isA<CircularDependencyError>()),
          );
        });

        test('a dependent', () {
          final scope = ScopeContext();
          late final Computed<int> b;
          late final Computed<int> c;
          b = Computed((watch) => watch(c) * 2);
          c = Computed((watch) => watch(b) * 2);

          expect(
            () => scope.read(b),
            throwsA(isA<CircularDependencyError>()),
          );
        });
      });

      group('[Creation]', () {
        test('should always be created in the lowest scope', () {
          final a = Variable((_) => 4);
          final scope1 = ScopeContext();
          final scope2 = ScopeContext(
            parent: scope1,
            overrides: {a.overrideWithValue(3)},
          );
          final c = Computed((watch) => watch(a) * 2);

          expect(scope1.read(a), equals(4));
          expect(scope2.read(c), equals(6));
          expect(scope2.read(a), equals(3));
          scope1.write(a, 5);
          expect(scope1.read(a), equals(5));
          expect(scope2.read(c), equals(6));
          expect(scope2.read(a), equals(3));
          scope2.write(a, 5);
          expect(scope1.read(a), equals(5));
          expect(scope2.read(c), equals(10));
          expect(scope2.read(a), equals(5));
        });
      });
    });

    group(
      '[Delete]',
      () {
        test('Should remove a node from its dependencies', () {
          final logs1 = <int>[];
          final v1 = Variable((_) => 4);
          final c1 = Computed((watch) {
            final result = watch(v1) * 2;
            logs1.add(result);
            return result;
          });

          final scope = ScopeContext();

          // creates v1 -> c1.
          scope.read(c1);
          expect(logs1, [8]);

          // updates v1, which should update c1.
          scope.update(v1, (x) => x + 1);
          expect(logs1, [8, 10]);

          // c1 should no longer exists.
          scope.delete(c1);

          // since c1 no longer exists, it should not be updated.
          scope.update(v1, (x) => x + 1);
          expect(logs1, [8, 10]);
        });

        test('Should remove a chain of nodes', () {
          const v = 4;
          final v1 = Variable((_) => v);

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

          final scope = ScopeContext();
          // Creates v1 -> c0 -> ... -> c9.
          scope.read(cx.last);

          for (int i = 0; i < max; i++) {
            final mult = math.pow(2, i + 1);
            expect(allLogs[i], [v * mult]);
          }

          // updates v1, which should update cO through c9.
          scope.update(v1, (x) => x + 1);
          for (int i = 0; i < max; i++) {
            final mult = math.pow(2, i + 1);
            expect(allLogs[i], [v * mult, (v + 1) * mult]);
          }

          // c9 should no longer exists and all the chain should also be deleted.
          scope.delete(cx.last);

          // since all the chain is deleted, they should not be updated.
          scope.update(v1, (x) => x + 1);
          for (int i = 0; i < max; i++) {
            final mult = math.pow(2, i + 1);
            expect(allLogs[i], [v * mult, (v + 1) * mult]);
          }
        });

        test('Should remove a chain of nodes across scopes', () {
          const v = 4;
          final v1 = Variable((_) => v);

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

          final scope1 = ScopeContext();
          final scope2 = ScopeContext(parent: scope1);
          final scope3 = ScopeContext(parent: scope2);
          final scope4 = ScopeContext(parent: scope3);

          scope4.read(v1);
          scope4.read(c1);
          scope4.read(c2);
          scope4.read(c3);

          for (int i = 0; i < max; i++) {
            final mult = math.pow(2, i + 1);
            expect(allLogs[i], [v * mult]);
          }

          // updates v1, which should update c1 through c3.
          scope1.update(v1, (x) => x + 1);
          for (int i = 0; i < max; i++) {
            final mult = math.pow(2, i + 1);
            expect(allLogs[i], [v * mult, (v + 1) * mult]);
          }

          // c3 should no longer exists and all the chain should also be deleted.
          scope4.delete(c3);

          // since all the chain is deleted, they should not be updated.
          scope1.update(v1, (x) => x + 1);
          for (int i = 0; i < max; i++) {
            final mult = math.pow(2, i + 1);
            expect(allLogs[i], [v * mult, (v + 1) * mult]);
          }
        });

        test('Should not be able to delete a node that has dependents', () {
          final v = Variable((_) => 3);
          final c = Computed((watch) => watch(v));
          final scope = ScopeContext();
          scope.read(c);
          expect(() => scope.delete(v), throwsA(isA<NodeHasDependentsError>()));
        });
      },
    );

    group('[Dispose]', () {
      test('Should not be able to dispose a scope with dependents', () {
        final scope1 = ScopeContext()..init();
        // ignore: unused_local_variable
        final scope2 = ScopeContext(parent: scope1)..init();

        expect(() => scope1.dispose(), throwsA(isA<ScopeHasDependentsError>()));
      });
    });
  });
}
