import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:state_watcher/src/core/refs.dart';
import 'package:state_watcher/src/core/state_observer.dart';

/// A widget that creates a new [Store].
class StateStore extends StatefulWidget {
  /// Creates a new [StateStore].
  const StateStore({
    super.key,
    this.overrides = const {},
    this.observers = const [],
    this.debugName,
    required this.child,
  });

  /// The name of the store.
  final String? debugName;

  /// The [Ref]s to override.
  final Set<Ref<Object?>> overrides;

  /// The observers observing the state changes of the store.
  final List<StateObserver> observers;

  /// The child widget.
  final Widget child;

  @override
  State<StateStore> createState() => _StateStoreState();
}

class _StateStoreState extends State<StateStore> {
  StoreNode? store;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    store ??= createStore();
  }

  StoreNode? createStore() {
    final parent = maybeDependOnParentStore(context);
    return StoreNode(
      parent: parent,
      debugName: widget.debugName,
      overrides: widget.overrides,
      observers: widget.observers,
    )..init();
  }

  @override
  void didUpdateWidget(covariant StateStore oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (store case final store?) {
      // If the overrides changed, we need to update the store overrides.
      if (!const DeepCollectionEquality()
          .equals(oldWidget.overrides, widget.overrides)) {
        store.updateOverrides(widget.overrides);
      }
      if (!const DeepCollectionEquality()
          .equals(oldWidget.observers, widget.observers)) {
        store.updateObservers(widget.observers);
      }
    }
  }

  @override
  void dispose() {
    store?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InheritedStateStore(
      store: store!,
      child: widget.child,
    );
  }
}

@internal

/// The context of a [Store].
StoreNode dependOnParentStore(BuildContext context, {bool listen = true}) {
  final storeNode = maybeDependOnParentStore(context, listen: listen);
  assert(() {
    if (storeNode == null) {
      throw FlutterError(
        '$StateStore.of() was called with a context that does not have access '
        'to a $StateStore widget.\n'
        'No $StateStore ancestor could be found starting from the context that '
        'was passed to $StateStore.of().\n'
        'The context used was:\n'
        '  $context',
      );
    }
    return true;
  }());
  return storeNode!;
}

@internal

/// The context of a [Store].
StoreNode? maybeDependOnParentStore(
  BuildContext context, {
  bool listen = true,
}) {
  final storeNode = (listen
      ? context.dependOnInheritedWidgetOfExactType<InheritedStateStore>()?.store
      : context.getInheritedWidgetOfExactType<InheritedStateStore>()?.store);

  return storeNode;
}

@internal
class InheritedStateStore extends InheritedWidget {
  const InheritedStateStore({
    super.key,
    required this.store,
    required super.child,
  });

  @internal
  final StoreNode store;

  @override
  bool updateShouldNotify(InheritedStateStore oldWidget) {
    return oldWidget.store != store;
  }
}
