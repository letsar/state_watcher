import 'package:flutter_test/flutter_test.dart';
import 'package:state_watcher/src/core/refs.dart';

void main() {
  group('Refs', () {
    test('toString() method should be their debugName', () {
      final refDefaultDebugNameP = Provided((_) => 0);
      expect(refDefaultDebugNameP.toString(), 'Provided<int>');

      final refCustomDebugNameP = Provided((_) => 0, debugName: 'custom');
      expect(refCustomDebugNameP.toString(), 'custom');

      final refDefaultDebugNameC = Computed((_) => 0);
      expect(refDefaultDebugNameC.toString(), 'Computed<int>');

      final refCustomDebugNameC = Computed((_) => 0, debugName: 'custom');
      expect(refCustomDebugNameC.toString(), 'custom');

      final refDefaultDebugNameO = Observed(() {});
      expect(refDefaultDebugNameO.toString(), 'Observed<void>');

      final refCustomDebugNameO = Observed(() {}, debugName: 'custom');
      expect(refCustomDebugNameO.toString(), 'custom');
    });

    test(
      'should throw CircularDependencyError error if there is a circular dependency',
      () {
        late Provided<_A> refA;
        late Provided<_B> refB;
        refA = Provided((read) => _A(read(refB)));
        refB = Provided((read) => _B(read(refA)));

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
