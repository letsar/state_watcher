import 'package:flutter_test/flutter_test.dart';
import 'package:state_watcher/src/core/refs.dart';

void main() {
  group('Refs', () {
    test('toString() method should their debugName', () {
      final refDefaultDebugNameV = Variable((_) => 0);
      expect(refDefaultDebugNameV.toString(), 'Variable<int>');

      final refCustomDebugNameV = Variable((_) => 0, debugName: 'custom');
      expect(refCustomDebugNameV.toString(), 'custom');

      final refDefaultDebugNameC = Computed((_) => 0);
      expect(refDefaultDebugNameC.toString(), 'Computed<int>');

      final refCustomDebugNameC = Computed((_) => 0, debugName: 'custom');
      expect(refCustomDebugNameC.toString(), 'custom');
    });

    test(
      'should throw CircularDependencyError error if there is a circular dependency',
      () {
        late Variable<_A> refA;
        late Variable<_B> refB;
        refA = Variable((read) => _A(read(refB)));
        refB = Variable((read) => _B(read(refA)));

        final store = StoreNode();
        expect(() => store.read(refA), throwsA(isA<CircularDependencyError>()));
      },
    );
  });
}

class _A {
  const _A(this.b);
  final _B b;
}

class _B {
  const _B(this.a);
  final _A a;
}
