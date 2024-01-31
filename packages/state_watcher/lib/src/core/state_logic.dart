part of 'refs.dart';

/// Mixin to apply in order to separate the logic from the view.
mixin StateLogic implements Disposable {
  late final ScopeContext _scope;

  // ignore: use_setters_to_change_properties
  void _init(ScopeContext scope) {
    _scope = scope;
  }

  /// Reads the value of the [ref].
  T read<T>(Ref<T> ref) {
    return _scope.read(ref);
  }

  /// Writes the [value] associated with the [ref].
  void write<T>(Variable<T> ref, T value) {
    _scope.write(ref, value);
  }

  /// Updates the value associated with the [ref] using the [updater].
  void update<T>(Variable<T> ref, Updater<T> updater) {
    _scope.update(ref, updater);
  }

  /// Deletes the [ref].
  void delete<T>(Ref<T> ref) {
    _scope.delete(ref);
  }

  @override
  void dispose() {}
}
