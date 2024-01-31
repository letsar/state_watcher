import 'package:flutter_test/flutter_test.dart';
import 'package:state_watcher/src/core/refs.dart';

final _refLogic = Variable((_) => _StateLogic());
bool deleted = false;

void main() {
  group('StateLogic', () {
    test('should be able to read', () {
      final scope = ScopeContext();
      final logic = scope.read(_refLogic);
      expect(logic, isNotNull);
      expect(logic.readVariable(), equals(4));
    });

    test('should be able to write', () {
      final scope = ScopeContext();
      final logic = scope.read(_refLogic);
      logic.writeVariable(5);
      expect(logic.readVariable(), equals(5));
    });

    test('should be able to update', () {
      final scope = ScopeContext();
      final logic = scope.read(_refLogic);
      logic.updateVariable((value) => value + 1);
      expect(logic.readVariable(), equals(5));
    });

    test('should be able to delete', () {
      final scope = ScopeContext();
      final logic = scope.read(_refLogic);
      logic.writeVariable(5);
      logic.deleteVariable();
      expect(logic.readVariable(), 4);
    });

    test('should be able to be disposed', () {
      deleted = false;
      final scope = ScopeContext();
      scope.read(_refLogic);
      expect(deleted, false);
      scope.delete(_refLogic);
      expect(deleted, true);
    });
  });
}

final variable = Variable((_) => 4);

class _StateLogic with StateLogic {
  _StateLogic();

  int readVariable() => read(variable);

  void writeVariable(int value) => write(variable, value);

  void updateVariable(int Function(int) updater) => update(variable, updater);

  void deleteVariable() => delete(variable);

  @override
  void dispose() {
    deleted = true;
    super.dispose();
  }
}
