import 'package:flutter_test/flutter_test.dart';
import 'package:state_watcher/src/core/disposable.dart';
import 'package:state_watcher/src/core/refs.dart';

void main() {
  test('Disposable should be disposed when deleted', () {
    bool disposed = false;
    final disposable = _Disposable(() {
      disposed = true;
    });

    final store = StoreNode();

    final refProvided = Provided((_) => disposable);
    store.read(refProvided);
    expect(disposed, false);
    store.delete(refProvided);
    expect(disposed, true);
  });
}

class _Disposable implements Disposable {
  const _Disposable(this.onDispose);
  final void Function() onDispose;

  @override
  void dispose() {
    onDispose();
  }
}
