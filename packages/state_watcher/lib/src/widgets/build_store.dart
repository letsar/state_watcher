import 'package:state_watcher/src/core/refs.dart';

/// Represents a store to within a build method.
abstract class BuildStore implements Store {
  /// Watches the changes of [ref] in this store.
  ///
  /// When the value of [ref] changes, the build method of the widget where
  /// the store is created from, is called again.
  T watch<T>(Ref<T> ref);
}
