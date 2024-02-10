import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:state_watcher/src/core/refs.dart';
import 'package:state_watcher/src/widgets/watcher_stateful_widget.dart';

/// Signature for a function when a state changes.
typedef StateChanged<T> = void Function(
  BuildContext context,
  T oldState,
  T newState,
);

/// Listen to the changes of [ref] and call [onStateChanged] when the state
/// changes.
class WatcherEffect<T> extends WatcherStatefulWidget {
  /// Creates a new [WatcherEffect].
  const WatcherEffect({
    super.key,
    required this.ref,
    required this.onStateChanged,
    this.debugName,
    this.child,
  });

  /// The [Ref] to listen to.
  final Ref<T> ref;

  @override
  final String? debugName;

  /// The callback to call when the state changes.
  final StateChanged<T> onStateChanged;

  /// The child widget.
  final Widget? child;

  @override
  State<WatcherEffect<T>> createState() => _WatcherEffectState<T>();
}

class _WatcherEffectState<T> extends State<WatcherEffect<T>> {
  bool initialized = false;
  late T oldValue;
  late Computed<void> computed;

  @override
  void initState() {
    super.initState();
    initComputed();
  }

  void initComputed() {
    final newComputed = Computed(
      (watch) {
        final newValue = watch(widget.ref);
        if (!initialized) {
          initialized = true;
          oldValue = newValue;
        } else {
          widget.onStateChanged(context, oldValue, newValue);
          oldValue = newValue;
        }
      },
      updateShouldNotify: (_, __) {
        // We always want to notify the Inspector in debug mode.
        return kDebugMode;
      },
      debugName: widget.debugName ?? 'WatcherEffect[${widget.ref.debugName}]',
    );
    // Read the ref to create the computed.
    computed = newComputed;
  }

  @override
  void didUpdateWidget(covariant WatcherEffect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ref.id != widget.ref.id) {
      initialized = false;
      initComputed();
    }
  }

  @override
  void dispose() {
    store.delete(computed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    store.watch(computed);
    return widget.child ?? const SizedBox.shrink();
  }
}
