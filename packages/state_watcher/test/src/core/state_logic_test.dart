import 'package:flutter_test/flutter_test.dart';
import 'package:state_watcher/src/core/refs.dart';

final _refLogic = Provided((_) => _StateLogic());
bool deleted = false;

void main() {
  group('StateLogic', () {
    test('should be able to read', () {
      final store = StoreNode();
      final logic = store.read(_refLogic);
      expect(logic, isNotNull);
      expect(logic.readProvided(), equals(4));
    });

    test('should be able to write', () {
      final store = StoreNode();
      final logic = store.read(_refLogic);
      logic.writeProvided(5);
      expect(logic.readProvided(), equals(5));
    });

    test('should be able to update', () {
      final store = StoreNode();
      final logic = store.read(_refLogic);
      logic.updateProvided((value) => value + 1);
      expect(logic.readProvided(), equals(5));
    });

    test('should be able to delete', () {
      final store = StoreNode();
      final logic = store.read(_refLogic);
      logic.writeProvided(5);
      logic.deleteProvided();
      expect(logic.readProvided(), 4);
    });

    test('should be able to be disposed', () {
      deleted = false;
      final store = StoreNode();
      store.read(_refLogic);
      expect(deleted, false);
      store.delete(_refLogic);
      expect(deleted, true);
    });
  });
}

final provided = Provided((_) => 4);

class _StateLogic with StateLogic {
  _StateLogic();

  int readProvided() => read(provided);

  void writeProvided(int value) => write(provided, value);

  void updateProvided(int Function(int) updater) => update(provided, updater);

  void deleteProvided() => delete(provided);

  @override
  void dispose() {
    deleted = true;
    super.dispose();
  }
}
