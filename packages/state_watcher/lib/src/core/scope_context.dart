part of 'refs.dart';

/// Object containing the actual states referenced by [Ref] instances.
@internal
class ScopeContext extends Scope {
  /// Creates a new [ScopeContext].
  ScopeContext({
    this.parent,
    Set<Ref<Object?>> overrides = const {},
    List<StateObserver> observers = const [],
    String? debugName,
  })  : _overrides = {
          for (final override in overrides) override.id: override,
        },
        _observers = observers,
        _nodes = {},
        debugName = debugName ?? 'Scope';

  final String debugName;
  final ScopeContext? parent;
  final Set<ScopeContext> _dependents = {};
  final Map<Object, Ref<Object?>> _overrides;
  final List<StateObserver> _observers;
  final Map<Object, Node<Object?>> _nodes;
  CircularDependencyDetector? _circularDependencyDetector;
  bool _disposing = false;

  static int _nextDebugId = 0;

  String _debugId = '';
  String get debugId => _debugId;

  void init() {
    if (kDebugMode) {
      _debugId = '${_nextDebugId++}';
    }
    _attach();
  }

  void _attach() {
    parent?._dependents.add(this);
  }

  void _detach() {
    parent?._dependents.remove(this);
  }

  void updateOverrides(Set<Ref<Object?>> overrides) {
    final oldOverrideIds = _overrides.keys.toSet();
    for (final override in overrides) {
      final id = override.id;
      final oldOverride = _overrides[id];
      _overrides[id] = override;
      oldOverrideIds.remove(id);
      final node = _nodes[id];
      if (oldOverride != null && node != null) {
        // We should maybe update the state.
        node.updateFromOverrides(oldOverride, override);
      }
    }

    // We should remove the old overrides.
    for (final oldOverrideId in oldOverrideIds) {
      _overrides.remove(oldOverrideId);
    }
  }

  void updateObservers(List<StateObserver> observers) {
    _observers.clear();
    _observers.addAll(observers);
  }

  @override
  bool hasStateFor<T>(Ref<T> ref) {
    return _nodes.containsKey(ref.id);
  }

  @override
  T read<T>(Ref<T> ref) {
    final node = _fetchOrCreateNodeFromTree(ref);
    return node.value;
  }

  @override
  void write<T>(Variable<T> ref, T value) {
    final node = _fetchOrCreateNodeFromTree(ref);
    node.value = value;
  }

  /// We need to be able to refresh a computed value, so that conditional
  /// dependencies can be updated in Flutter.
  void refresh<T>(Computed<T> ref) {
    final node = _fetchOrCreateNodeFromTree(ref);
    if (kDebugMode) {
      StateInspector.instance.mutePostUpdateEvent(() {
        node.update();
      });
    }
  }

  @override
  void update<T>(Variable<T> ref, Updater<T> update) {
    write(ref, update(read(ref)));
  }

  @override
  void delete<T>(Ref<T> ref) {
    final node = _fetchOrCreateNodeFromTree(ref);

    if (!_disposing && node.hasDependents) {
      throw NodeHasDependentsError(node);
    }

    // First we need to remove this node from its dependencies in order to
    // avoid memory leaks.
    final dependencies = node._dependencies.toList();
    for (final dependency in dependencies) {
      node.removeDependency(dependency);
    }

    _nodes.remove(ref.id);

    // We also need to dispose any disposable value.
    final value = node.value;
    if (value is Disposable) {
      value.dispose();
    }

    _stateDeleted(node);
  }

  Node<T> _createNode<T>(Ref<T> ref) {
    final circularDependencyDetector =
        _circularDependencyDetector ??= CircularDependencyDetector(ref.id);
    circularDependencyDetector.startVisiting(ref.id);
    final node = ref._createNode(this);
    node.init();
    _stateCreated(node);
    circularDependencyDetector.endVisiting(ref.id);
    if (circularDependencyDetector.isEmpty) {
      _circularDependencyDetector = null;
    }
    return node;
  }

  Node<T> _fetchOrCreateNode<T>(Ref<T> ref) {
    final node = _nodes.putIfAbsent(ref.id, () {
      return _createNode<T>(ref);
    });
    return node as Node<T>;
  }

  Node<T> _fetchOrCreateNodeFromTree<T>(Ref<T> ref) {
    // In case of an override, we always fetch the value from the scope where
    // the override is defined.
    final override = _overrides[ref.id] as Ref<T>?;
    if (override != null) {
      return _fetchOrCreateNode(override);
    }

    final node = switch (ref) {
      // For a Variable the rule is to fetch the value from the
      // root scope.
      Variable<T>() => () {
          final parent = this.parent;
          if (parent == null) {
            // We can get the value from this scope.
            return _fetchOrCreateNode(ref);
          }

          // We need to fetch it from its parent.
          return parent._fetchOrCreateNodeFromTree(ref);
        }(),

      // For a Computed, we need to fetch the value from the nearest scope,
      // because in case of dependency overrides, we need to get those values
      // from the nearest scope.
      Computed<T>() => _fetchOrCreateNode(ref),
    };
    return node;
  }

  void _stateCreated<T>(Node<T> node) {
    for (final observer in _observers) {
      observer.didStateCreated(node.scope, node.ref, node.value);
    }
    if (kDebugMode && parent == null) {
      StateInspector.instance.didStateCreated(node);
    }
    parent?._stateCreated(node);
  }

  void _stateUpdated<T>(Node<T> node, T oldValue, T newValue) {
    for (final observer in _observers) {
      observer.didStateUpdated(node.scope, node.ref, oldValue, newValue);
    }

    parent?._stateUpdated(node, oldValue, newValue);
  }

  void _stateDeleted<T>(Node<T> node) {
    for (final observer in _observers) {
      observer.didStateDeleted(node.scope, node.ref);
    }
    if (kDebugMode && parent == null) {
      StateInspector.instance.didStateDeleted(node);
    }
    parent?._stateDeleted(node);
  }

  void dispose() {
    if (_dependents.isNotEmpty) {
      throw ScopeHasDependentsError(this);
    }

    _disposing = true;

    _detach();

    // We need to delete all the nodes.
    final refs = _nodes.values.toList();

    // We can safely clear the node in any order because they can't have a
    // dependent in a child scope.
    for (final ref in refs) {
      delete(ref.ref);
    }
  }
}

@internal
abstract class Node<T> {
  Node(this.scope)
      : _dependencies = {},
        _dependents = {};

  final ScopeContext scope;

  /// Nodes which this node depends on.
  final Set<Node<Object?>> _dependencies;

  /// Nodes which depends on this node.
  final Set<Node<Object?>> _dependents;

  bool _shouldNotifyInspector = false;

  bool get hasDependents {
    return _dependents.isNotEmpty;
  }

  Ref<T> get ref;

  static int _nextDebugId = 0;

  String _debugId = '';
  String get debugId => _debugId;

  T get value => _value;
  late T _value;
  set value(T newValue) {
    final oldValue = _value;
    _value = newValue;

    final shouldUpdateDependents = ref.updateShouldNotify(oldValue, newValue);

    if (kDebugMode && (shouldUpdateDependents || _shouldNotifyInspector)) {
      StateInspector.instance.didStateUpdated(this);
      _shouldNotifyInspector = false;
    }

    if (shouldUpdateDependents) {
      scope._stateUpdated(this, oldValue, newValue);
      // We make a new list to avoid concurrent modification.
      final dependents = _dependents.toList();
      for (final dependent in dependents) {
        dependent.update();
      }
    }
  }

  bool addDependency(Node<Object?> dependency) {
    dependency._throwIfDependsOn(this);
    _dependencies.add(dependency);
    return dependency._dependents.add(this);
  }

  bool removeDependency(Node<Object?> dependency) {
    _dependencies.remove(dependency);
    final result = dependency._dependents.remove(this);

    if (!dependency.hasDependents && dependency.ref.autoDispose) {
      // If the dependency has no longer dependents, maybe we can remove from
      // its scope.
      dependency.detach();
    }
    return result;
  }

  void _throwIfDependsOn(Node<Object?> node) {
    if (_dependencies.contains(node)) {
      throw CircularDependencyError(this.ref.id, node.ref.id);
    }

    for (final dependency in _dependencies) {
      dependency._throwIfDependsOn(node);
    }
  }

  @mustCallSuper
  void init() {
    if (kDebugMode) {
      _debugId = '${_nextDebugId++}';
    }
  }

  void update();

  void detach() {
    scope.delete(ref);
  }

  void updateFromOverrides(
    covariant Ref<T> oldOverride,
    covariant Ref<T> newOverride,
  ) {}

  Map<String, Object> toJson() {
    final metadata = ref.metadata;
    final debugName = metadata.debugName;

    return {
      'id': debugId,
      'debugName': debugName is DebugName ? debugName.name : ref.id.toString(),
      'refType': metadata.refType,
      'valueType': metadata.valueType,
      'customName': metadata.isCustomName,
      'scopeId': scope.debugId,
      'scopeDebugName': scope.debugName,
      'dependencies': _dependencies.map((d) => d.debugId).toList(),
      'value': '$value',
      if (debugName is DebugName) ...{
        'file': debugName.file,
        'line': debugName.line,
        'column': debugName.column,
      },
    };
  }
}

@internal
class VariableNode<T> extends Node<T> {
  VariableNode(this.ref, super.scope);

  @override
  Variable<T> ref;

  @override
  void init() {
    super.init();
    _value = _createValue(ref);
  }

  T _createValue(Variable<T> ref) {
    final value = ref._create(scope.read);
    if (value is StateLogic) {
      value._init(scope);
    }
    return value;
  }

  @override
  void update() {}

  @override
  void updateFromOverrides(
    covariant Variable<T> oldOverride,
    covariant Variable<T> newOverride,
  ) {
    final oldValue = _createValue(oldOverride);
    final newValue = _createValue(newOverride);

    // We only want to update the value if the overrides are different and if
    // the value didn't change since the last override.
    if (ref.updateShouldNotify(oldValue, newValue) &&
        !ref.updateShouldNotify(_value, oldValue)) {
      value = newValue;
    }
  }
}

@internal
class ComputedNode<T> extends Node<T> {
  ComputedNode(this.ref, super.scope);

  @override
  Computed<T> ref;

  @override
  void init() {
    super.init();
    _value = compute();
  }

  @override
  void update() {
    value = compute();
  }

  T compute() {
    final oldDependencies = _dependencies.toSet();
    bool dependenciesChanged = false;

    X watch<X>(Ref<X> ref) {
      final node = scope._fetchOrCreateNodeFromTree(ref);
      dependenciesChanged |= addDependency(node);
      oldDependencies.remove(node);
      return node.value;
    }

    final value = ref._compute(watch);
    if (kDebugMode) {
      dependenciesChanged |= oldDependencies.isNotEmpty;
    }
    for (final dependency in oldDependencies) {
      // The remaining dependencies are no longer dependencies.
      removeDependency(dependency);
    }

    // We need to notify the inspector if the dependencies changed.
    _shouldNotifyInspector = kDebugMode && dependenciesChanged;

    return value;
  }
}

@internal
class CircularDependencyDetector {
  CircularDependencyDetector(this.nodeId);

  final Object nodeId;
  final Set<Object> _visited = {};

  bool get isEmpty => _visited.isEmpty;

  void startVisiting(Object id) {
    if (_visited.contains(id)) {
      throw CircularDependencyError(nodeId, id);
    }
    _visited.add(id);
  }

  void endVisiting(Object id) {
    _visited.remove(id);
  }
}

/// An error thrown when a circular dependency is detected.
class CircularDependencyError extends Error {
  /// Creates a new [CircularDependencyError].
  CircularDependencyError(this.node, this.dependency);

  /// The node which depends on [dependency].
  final Object node;

  /// The node which [node] depends on.
  final Object dependency;

  @override
  String toString() {
    return 'Circular dependency detected: $node already depends on $dependency';
  }
}

/// An error throw when something cannot be deleted because it has dependents.
class HasDependentsError extends Error {
  /// Creates a new [HasDependentsError].
  HasDependentsError();
}

/// An error throw when a scope cannot be deleted because it has dependents.
class ScopeHasDependentsError extends HasDependentsError {
  /// Creates a new [ScopeHasDependentsError].
  ScopeHasDependentsError(this.scope);

  /// The scope which has dependents.
  final ScopeContext scope;

  @override
  String toString() {
    return 'Cannot delete $scope because it has dependents';
  }
}

/// An error throw when a node cannot be deleted because it has dependents.
class NodeHasDependentsError extends HasDependentsError {
  /// Creates a new [NodeHasDependentsError].
  NodeHasDependentsError(this.node);

  /// The node which has dependents.
  final Node<Object?> node;

  @override
  String toString() {
    return 'Cannot delete $node because it has ${node._dependents.length} dependents.';
  }
}

@internal
class DebugName {
  const DebugName({
    required this.name,
    required this.file,
    required this.line,
    required this.column,
  });

  final String name;
  final String file;
  final int line;
  final int column;

  @override
  String toString() {
    return '$name($file:$line:$column)';
  }
}
