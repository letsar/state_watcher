import 'package:state_watcher/src/core/refs.dart';
import 'package:state_watcher/src/core/state_observer.dart';

class DelegatedStateObserver extends StateObserver {
  DelegatedStateObserver({
    this.onStateCreated,
    this.onStateUpdated,
    this.onStateDeleted,
  });

  final void Function(Store, Ref<Object?>, Object?)? onStateCreated;
  final void Function(Store, Ref<Object?>, Object?, Object?)? onStateUpdated;
  final void Function(Store, Ref<Object?>)? onStateDeleted;

  @override
  void didStateCreated<T>(Store store, Ref<T> ref, T value) {
    onStateCreated?.call(store, ref, value);
  }

  @override
  void didStateUpdated<T>(Store store, Ref<T> ref, T oldValue, T newValue) {
    onStateUpdated?.call(store, ref, oldValue, newValue);
  }

  @override
  void didStateDeleted<T>(Store store, Ref<T> ref) {
    onStateDeleted?.call(store, ref);
  }
}
