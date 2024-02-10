import 'package:state_watcher/src/core/refs.dart';
import 'package:state_watcher/src/core/state_observer.dart';

class DelegatedStateObserver extends StateObserver {
  DelegatedStateObserver({
    this.onStateCreated,
    this.onStateUpdated,
    this.onStateDeleted,
  });

  final void Function(Ref<Object?>, Object?)? onStateCreated;
  final void Function(Ref<Object?>, Object?, Object?)? onStateUpdated;
  final void Function(Ref<Object?>)? onStateDeleted;

  @override
  void didStateCreated<T>(Ref<T> ref, T value) {
    onStateCreated?.call(ref, value);
  }

  @override
  void didStateUpdated<T>(Ref<T> ref, T oldValue, T newValue) {
    onStateUpdated?.call(ref, oldValue, newValue);
  }

  @override
  void didStateDeleted<T>(Ref<T> ref) {
    onStateDeleted?.call(ref);
  }
}
