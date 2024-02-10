import 'package:flutter_test/flutter_test.dart';
import 'package:state_watcher/src/core/refs.dart';
import 'package:state_watcher/src/core/state_observer.dart';

void main() {
  final observer = _StateObserver();

  setUp(() {
    observer.reset();
  });

  group('StateObserver', () {
    test('should call didStateCreated when state created', () {
      final store = StoreNode(observers: [observer]);
      final a = Provided((_) => 4, debugName: 'a');
      expect(observer.logs, isEmpty);
      store.read(a);
      expect(observer.logs, ['didStateCreated a with 4']);
    });

    test('should call didStateUpdated when state updated', () {
      final store = StoreNode(observers: [observer]);
      final a = Provided((_) => 4, debugName: 'a');
      expect(observer.logs, isEmpty);
      store.read(a);
      store.write(a, 5);
      expect(observer.logs, [
        'didStateCreated a with 4',
        'didStateUpdated a from 4 to 5',
      ]);
    });

    test('should call didStateDeleted when state deleted', () {
      final store = StoreNode(observers: [observer]);
      final a = Provided((_) => 4, debugName: 'a');
      expect(observer.logs, isEmpty);
      store.read(a);
      store.delete(a);
      expect(observer.logs, [
        'didStateCreated a with 4',
        'didStateDeleted a',
      ]);
    });
  });
}

class _StateObserver extends StateObserver {
  final logs = <String>[];

  @override
  void didStateCreated<T>(Ref<T> ref, T value) {
    logs.add('didStateCreated ${ref.debugName} with $value');
  }

  @override
  void didStateUpdated<T>(Ref<T> ref, T oldValue, T newValue) {
    logs.add('didStateUpdated ${ref.debugName} from $oldValue to $newValue');
  }

  @override
  void didStateDeleted<T>(Ref<T> ref) {
    logs.add('didStateDeleted ${ref.debugName}');
  }

  void reset() {
    logs.clear();
  }
}
