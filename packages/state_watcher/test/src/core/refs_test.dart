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
  });
}
