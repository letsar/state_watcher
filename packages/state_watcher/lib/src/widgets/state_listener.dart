import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:state_watcher/src/core/refs.dart';
import 'package:state_watcher/src/widgets/build_scope.dart';
import 'package:state_watcher/src/widgets/watcher_stateless_widget.dart';

/// Signature for a function when a state changes.
typedef StateChanged<T> = void Function(
  BuildContext context,
  T oldState,
  T newState,
);

/// Listen to the changes of [ref] and call [onStateChanged] when the state
/// changes.
class StateListener<T> extends WatcherStatelessWidget {
  /// Creates a new [StateListener].
  const StateListener({
    super.key,
    required this.ref,
    required this.onStateChanged,
    required this.child,
  });

  /// The [Ref] to listen to.
  final Ref<T> ref;

  /// The callback to call when the state changes.
  final StateChanged<T> onStateChanged;

  /// The child widget.
  final Widget child;

  @override
  Widget build(BuildContext context, BuildScope scope) {
    return ValueListener<T>(
      value: scope.watch(ref),
      updateShouldNotify: ref.updateShouldNotify,
      onStateChanged: onStateChanged,
      child: child,
    );
  }
}

@internal
class ValueListener<T> extends StatefulWidget {
  const ValueListener({
    super.key,
    required this.value,
    required this.updateShouldNotify,
    required this.onStateChanged,
    required this.child,
  });

  final T value;
  final AreDifferent<T> updateShouldNotify;
  final StateChanged<T> onStateChanged;
  final Widget child;

  @override
  State<ValueListener<T>> createState() => _ValueListenerState<T>();
}

class _ValueListenerState<T> extends State<ValueListener<T>> {
  @override
  void didUpdateWidget(covariant ValueListener<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldValue = oldWidget.value;
    final newValue = widget.value;
    if (widget.updateShouldNotify(oldValue, newValue)) {
      widget.onStateChanged(context, oldValue, newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
