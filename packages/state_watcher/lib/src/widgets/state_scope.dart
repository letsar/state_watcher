import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:state_watcher/src/core/refs.dart';
import 'package:state_watcher/src/core/state_observer.dart';

/// A widget that creates a new [Scope].
class StateScope extends StatefulWidget {
  /// Creates a new [StateScope].
  const StateScope({
    super.key,
    this.overrides = const {},
    this.observers = const [],
    this.debugName,
    required this.child,
  });

  /// The name of the scope.
  final String? debugName;

  /// The [Ref]s to override.
  final Set<Ref<Object?>> overrides;

  /// The observers observing the state changes of the scope.
  final List<StateObserver> observers;

  /// The child widget.
  final Widget child;

  /// Gets the [Scope] of the closest [StateScope] ancestor.
  static Scope of(BuildContext context, {bool listen = true}) {
    return dependOnParentScope(context, listen: listen);
  }

  @override
  State<StateScope> createState() => _StateScopeState();
}

class _StateScopeState extends State<StateScope> {
  ScopeContext? scope;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scope ??= createScope();
  }

  ScopeContext? createScope() {
    final parent = maybeDependOnParentScope(context);
    return ScopeContext(
      parent: parent,
      debugName: widget.debugName,
      overrides: widget.overrides,
      observers: widget.observers,
    )..init();
  }

  @override
  void didUpdateWidget(covariant StateScope oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (scope case final scope?) {
      // If the overrides changed, we need to update the scope overrides.
      if (!const DeepCollectionEquality()
          .equals(oldWidget.overrides, widget.overrides)) {
        scope.updateOverrides(widget.overrides);
      }
      if (!const DeepCollectionEquality()
          .equals(oldWidget.observers, widget.observers)) {
        scope.updateObservers(widget.observers);
      }
    }
  }

  @override
  void dispose() {
    scope?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InheritedStateScope(
      scope: scope!,
      child: widget.child,
    );
  }
}

@internal

/// The context of a [Scope].
ScopeContext dependOnParentScope(BuildContext context, {bool listen = true}) {
  final scopeContext = maybeDependOnParentScope(context, listen: listen);
  assert(() {
    if (scopeContext == null) {
      throw FlutterError(
        '$StateScope.of() was called with a context that does not have access '
        'to a $StateScope widget.\n'
        'No $StateScope ancestor could be found starting from the context that '
        'was passed to $StateScope.of().\n'
        'The context used was:\n'
        '  $context',
      );
    }
    return true;
  }());
  return scopeContext!;
}

@internal

/// The context of a [Scope].
ScopeContext? maybeDependOnParentScope(
  BuildContext context, {
  bool listen = true,
}) {
  final scopeContext = (listen
      ? context.dependOnInheritedWidgetOfExactType<InheritedStateScope>()?.scope
      : context.getInheritedWidgetOfExactType<InheritedStateScope>()?.scope);

  return scopeContext;
}

@internal
class InheritedStateScope extends InheritedWidget {
  const InheritedStateScope({
    super.key,
    required this.scope,
    required super.child,
  });

  @internal
  final ScopeContext scope;

  @override
  bool updateShouldNotify(InheritedStateScope oldWidget) {
    return oldWidget.scope != scope;
  }
}
