import 'package:state_watcher/src/core/refs.dart';

/// Represents a scope to within a build method.
abstract class BuildScope implements Scope {
  /// Watches the changes of [ref] in this scope.
  ///
  /// When the value of [ref] changes, the build method of the widget where
  /// the scope is created from, is called again.
  T watch<T>(Ref<T> ref);
}
