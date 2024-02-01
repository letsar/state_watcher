part of 'refs.dart';

/// Mixin to apply in order to separate the logic from the view.
mixin StateLogic implements Disposable {
  late final StoreNode _store;

  // ignore: use_setters_to_change_properties
  void _init(StoreNode store) {
    _store = store;
  }

  /// Reads the value of the [ref].
  T read<T>(Ref<T> ref) {
    return _store.read(ref);
  }

  /// Writes the [value] associated with the [ref].
  void write<T>(Variable<T> ref, T value) {
    _store.write(ref, value);
  }

  /// Updates the value associated with the [ref] using the [updater].
  void update<T>(Variable<T> ref, Updater<T> updater) {
    _store.update(ref, updater);
  }

  /// Deletes the [ref].
  void delete<T>(Ref<T> ref) {
    _store.delete(ref);
  }

  @override
  void dispose() {}
}
