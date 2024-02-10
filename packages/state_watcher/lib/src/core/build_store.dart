import 'package:state_watcher/src/core/refs.dart';

/// Represents a store to within a build method.
abstract class BuildStore {
  /// Indicates whether [ref] has a value inside this [Store].
  bool hasStateFor<T>(Ref<T> ref);

  /// The number of states located in this [Store].
  int get stateCount;

  /// Reads the value of [ref] from this [Store].
  T read<T>(Ref<T> ref);

  /// Watches the changes of [ref] in this store.
  ///
  /// When the value of [ref] changes, the build method of the widget where
  /// the store is created from, is called again.
  T watch<T>(Ref<T> ref);

  /// Writes the [value] associated with [ref] in this [Store].
  void write<T>(Provided<T> ref, T value);

  /// Updates the value associated with [ref] in this [Store] using the
  /// [updater].
  void update<T>(Provided<T> ref, Updater<T> update) {
    write(ref, update(read(ref)));
  }

  /// Deletes the value associated with [ref] from this [Store].
  void delete<T>(Ref<T> ref);
}
