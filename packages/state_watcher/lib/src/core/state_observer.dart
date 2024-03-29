import 'package:state_watcher/src/core/refs.dart';

/// Interface for observing state changes.
abstract class StateObserver {
  /// Constant constructor for classe which extends this.
  const StateObserver();

  /// Called when a [Ref] is created.
  void didStateCreated<T>(Ref<T> ref, T value);

  /// Called when a [Ref] is updated.
  void didStateUpdated<T>(Ref<T> ref, T oldValue, T newValue);

  /// Called when a [Ref] is deleted.
  void didStateDeleted<T>(Ref<T> ref);
}
