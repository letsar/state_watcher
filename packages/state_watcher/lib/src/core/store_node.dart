part of 'refs.dart';

/// Object containing the actual states referenced by [Ref] instances.
///
/// Can have a parent store.
@internal
class StoreNode {
  /// Creates a new [StoreNode].
  StoreNode({
    this.parent,
    Set<Ref<Object?>> overrides = const {},
    List<StateObserver> observers = const [],
    String? debugName,
  })  : _overrides = {
          for (final override in overrides) override.id: override,
        },
        _observers = observers,
        _nodes = {},
        debugName = debugName ?? 'Store';

  final String debugName;
  final StoreNode? parent;
  final Set<StoreNode> _dependents = {};
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

  bool hasStateFor<T>(Ref<T> ref) {
    return _nodes.containsKey(ref.id);
  }

  int get stateCount => _nodes.length;

  T read<T>(Ref<T> ref) {
    final node = _fetchOrCreateNodeFromTree(ref);
    return node.value;
  }

  void write<T>(Provided<T> ref, T value) {
    final node = _fetchOrCreateNodeFromTree(ref);
    node.value = value;
  }

  void update<T>(Provided<T> ref, Updater<T> update) {
    write(ref, update(read(ref)));
  }

  void delete<T>(Ref<T> ref) {
    if (!hasStateFor(ref)) {
      // The ref is not in this store, nothing to do.
      return;
    }

    final node = _fetchOrCreateNodeFromTree(ref);

    if (!_disposing && node.hasWatchers) {
      throw NodeHasWatchersError(node);
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

  Node<T>? _fetchNode<T>(Ref<T> ref, {bool create = true}) {
    final node = create
        ? _nodes.putIfAbsent(ref.id, () {
            return _createNode<T>(ref);
          })
        : _nodes[ref.id];

    return node as Node<T>?;
  }

  Node<T> _fetchOrCreateNodeFromTree<T>(Ref<T> ref) {
    return _fetchNodeFromTree<T>(ref, create: true)!;
  }

  Node<T>? _fetchNodeFromTree<T>(Ref<T> ref, {required bool create}) {
    // In case of an override, we always fetch the value from the store where
    // the override is defined.
    final override = _overrides[ref.id] as Ref<T>?;
    if (override != null) {
      return _fetchNode(override, create: create);
    }

    final parent = this.parent;
    if (!ref.global || parent == null) {
      return _fetchNode(ref, create: create);
    }

    return parent._fetchNodeFromTree(ref, create: create);
  }

  void _stateCreated<T>(Node<T> node) {
    for (final observer in _observers) {
      observer.didStateCreated(node.ref, node.value);
    }
    if (kDebugMode && parent == null) {
      StateInspector.instance.didStateCreated(node);
    }
    parent?._stateCreated(node);
  }

  void _stateUpdated<T>(Node<T> node, T oldValue, T newValue) {
    for (final observer in _observers) {
      observer.didStateUpdated(node.ref, oldValue, newValue);
    }

    parent?._stateUpdated(node, oldValue, newValue);
  }

  void _stateDeleted<T>(Node<T> node) {
    for (final observer in _observers) {
      observer.didStateDeleted(node.ref);
    }
    if (kDebugMode && parent == null) {
      StateInspector.instance.didStateDeleted(node);
    }
    parent?._stateDeleted(node);
  }

  void dispose() {
    if (_dependents.isNotEmpty) {
      throw StoreHasDependentsError(this);
    }

    _disposing = true;

    _detach();

    // We need to delete all the nodes.
    final refs = _nodes.values.toList();

    // We can safely clear the node in any order because they can't have a
    // dependent in a child store.
    for (final ref in refs) {
      delete(ref.ref);
    }
  }
}

@internal
abstract class Node<T> extends BuildStore {
  Node(this.store)
      : _dependencies = {},
        _dependents = {},
        _watchers = {};

  final StoreNode store;

  /// Nodes which this node depends on.
  final Set<Node<Object?>> _dependencies;

  /// Nodes which depends on this node.
  final Set<Node<Object?>> _dependents;

  /// Nodes which watches this node.
  /// This is a subset of _dependents.
  final Set<Node<Object?>> _watchers;

  Set<Node<Object?>>? _oldDependencies;
  bool _hasDependenciesChanged = false;

  bool _shouldNotifyInspector = false;

  bool get hasDependents {
    return _dependents.isNotEmpty;
  }

  bool get hasWatchers {
    return _watchers.isNotEmpty;
  }

  Ref<T> get ref;

  static int _nextDebugId = 0;

  String _debugId = '';
  String get debugId => _debugId;

  @override
  int get stateCount => store.stateCount;

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
      store._stateUpdated(this, oldValue, newValue);
      // We make a new list to avoid concurrent modification.
      final watchers = _watchers.toList();
      for (final watcher in watchers) {
        watcher.rebuild();
      }
    }
  }

  void addDependency(Node<Object?> dependency, {required bool watch}) {
    dependency._throwIfDependsOn(this);
    _dependencies.add(dependency);

    final added = dependency._dependents.add(this);
    if (watch) {
      dependency._watchers.add(this);
    }
    if (_oldDependencies case final oldDependencies?) {
      _hasDependenciesChanged |= added;
      oldDependencies.remove(dependency);
    }
  }

  void removeDependency(Node<Object?> dependency) {
    _dependencies.remove(dependency);
    dependency._dependents.remove(this);
    dependency._watchers.remove(this);

    if (!dependency.hasDependents && dependency.ref.autoDispose) {
      // If the dependency has no longer dependents, maybe we can remove from
      // its store.
      dependency.detach();
    }
  }

  X fetchValue<X>(Ref<X> ref, {required bool watch}) {
    final node = store._fetchOrCreateNodeFromTree(ref);
    addDependency(node, watch: watch);
    return node.value;
  }

  @override
  X read<X>(Ref<X> ref) {
    return fetchValue(ref, watch: false);
  }

  @override
  X watch<X>(Ref<X> ref) {
    return fetchValue(ref, watch: true);
  }

  void unwatch<X>(Ref<X> ref) {
    final node = store._fetchNodeFromTree(ref, create: false);
    if (node != null) {
      removeDependency(node);
    }
  }

  @override
  void write<X>(Provided<X> ref, X value) {
    final node = store._fetchOrCreateNodeFromTree(ref);
    addDependency(node, watch: false);
    node.value = value;
  }

  X trackDependencyChanges<X>(X Function() callback) {
    startTrackingDependencies();
    final result = callback();
    endTrackingDependencies();
    return result;
  }

  @override
  bool hasStateFor<X>(Ref<X> ref) => store.hasStateFor(ref);

  @override
  void delete<X>(Ref<X> ref) {
    store.delete(ref);
  }

  void startTrackingDependencies() {
    _oldDependencies = _dependencies.toSet();
    _hasDependenciesChanged = false;
  }

  void endTrackingDependencies() {
    if (_oldDependencies case final oldDependencies?) {
      if (kDebugMode) {
        _hasDependenciesChanged |= oldDependencies.isNotEmpty;
      }
      for (final dependency in oldDependencies) {
        // The remaining dependencies are no longer dependencies.
        removeDependency(dependency);
      }

      // We need to notify the inspector if the dependencies changed.
      _shouldNotifyInspector = kDebugMode && _hasDependenciesChanged;
    }
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

  void rebuild();

  void detach() {
    store.delete(ref);
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
      'debugName': debugName,
      'refType': metadata.refType,
      'valueType': metadata.valueType,
      'customName': metadata.isCustomName,
      'storeId': store.debugId,
      'storeDebugName': store.debugName,
      'dependencies': _dependencies.map((d) => d.debugId).toList(),
      'value': '$value',
    };
  }
}

@internal
class ProvidedNode<T> extends Node<T> implements Reader {
  ProvidedNode(this.ref, super.store);

  @override
  Provided<T> ref;

  @override
  void init() {
    super.init();
    _value = _createValue(ref);
  }

  @override
  X call<X>(Ref<X> ref) => read<X>(ref);

  T _createValue(Provided<T> ref) {
    final value = ref._create(this);
    if (value is StateLogic) {
      value._init(this);
    }
    return value;
  }

  @override
  void rebuild() {}

  @override
  void updateFromOverrides(
    covariant Provided<T> oldOverride,
    covariant Provided<T> newOverride,
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
class ComputedNode<T> extends Node<T> implements Watcher {
  ComputedNode(this.ref, super.store);

  @override
  Computed<T> ref;

  @override
  void init() {
    super.init();
    _value = compute();
  }

  @override
  void rebuild() {
    value = compute();
  }

  T compute() {
    return trackDependencyChanges(() => ref._compute(this));
  }

  @override
  X call<X>(Ref<X> ref) => watch<X>(ref);

  @override
  void cancel<X>(Ref<X> ref) => unwatch<X>(ref);
}

@internal
class ObservedNode extends Node<ObservedNode> {
  ObservedNode(this.ref, super.store);

  @override
  Observed ref;

  @override
  void init() {
    super.init();
    _value = this;
  }

  @override
  void rebuild() {
    ref.onDependencyChanged();
    if (kDebugMode) {
      StateInspector.instance.didStateUpdated(this);
    }
  }

  @override
  Map<String, Object> toJson() {
    final json = super.toJson();

    if (ref.location case final location?) {
      json['file'] = location.file;
      json['line'] = location.line;
      json['column'] = location.column;
    }

    return json;
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

/// An error throw when a store cannot be deleted because it has dependents.
class StoreHasDependentsError extends HasDependentsError {
  /// Creates a new [StoreHasDependentsError].
  StoreHasDependentsError(this.store);

  /// The store which has dependents.
  final StoreNode store;

  @override
  String toString() {
    return 'Cannot delete $store because it has dependents';
  }
}

/// An error throw when a node cannot be deleted because it has watchers.
class NodeHasWatchersError extends HasDependentsError {
  /// Creates a new [NodeHasWatchersError].
  NodeHasWatchersError(this.node);

  /// The node which has watchers.
  final Node<Object?> node;

  @override
  String toString() {
    return 'Cannot delete $node because it has ${node._watchers.length} watchers.';
  }
}
