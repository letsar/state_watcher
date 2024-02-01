import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:state_watcher/src/core/refs.dart';
import 'package:state_watcher/src/widgets/build_store.dart';
import 'package:state_watcher/src/widgets/state_store.dart';

@internal
mixin WatcherElement on ComponentElement {
  final Set<Ref<Object?>> _dependencies = {};
  String? get debugName;

  late final BuildStore buildStore = _BuildStore(this);

  StoreNode? _store;
  StoreNode? get store => _store;
  set store(StoreNode? newStore) {
    if (newStore != _store) {
      _store?.delete(computed);
      _store = newStore;
    }
  }

  late final computed = Computed<void>(
    compute,
    debugName: debugName ?? defaultDebugName(),
    updateShouldNotify: (_, __) {
      // We alaways want to notify the Inspector in debug mode.
      return kDebugMode;
    },
  );

  void compute(Reader watch) {
    for (final dependency in _dependencies) {
      watch(dependency);
    }
    if (mounted) {
      markNeedsBuild();
    }
  }

  Object defaultDebugName() {
    Object debugName = '';
    if (kDebugMode) {
      debugName = fetchElementDebugName();
    }
    return debugName;
  }

  Object fetchElementDebugName() {
    final service = WidgetInspectorService.instance;
    if (service.isWidgetCreationTracked()) {
      final delegate = InspectorSerializationDelegate(service: service);
      final parentNode = toDiagnosticsNode();
      final map = delegate.additionalNodeProperties(parentNode);

      if (map['creationLocation'] case final Map<String, Object?> loc?) {
        final file = loc['file']! as String;
        final name = loc['name'] as String?;
        final line = loc['line']! as int;
        final column = loc['column']! as int;

        return DebugName(
          name: 'Watcher[$name]',
          file: file,
          line: line,
          column: column,
        );
      }
    }

    return 'Watcher[${toStringShort()}]';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    store = dependOnParentStore(this);
  }

  @override
  void unmount() {
    _dependencies.clear();
    _store?.delete(computed);
    super.unmount();
  }

  @override
  Widget build() {
    // We need to clear the dependencies before building the widget in case we
    // have conditional dependencies.
    _dependencies.clear();
    final result = super.build();

    /// We need to read the computed value to register the dependencies.
    _store?.refresh(computed);
    return result;
  }
}

class _BuildStore implements BuildStore {
  _BuildStore(this.element);

  final WatcherElement element;

  @override
  T watch<T>(Ref<T> ref) {
    assert(
      element.debugDoingBuild,
      'Cannot watch the state outside of the build method.',
    );
    final store = element.store ??= dependOnParentStore(element);
    element._dependencies.add(ref);
    return store.read(ref);
  }

  @override
  bool hasStateFor<T>(Ref<T> ref) {
    return fetchStore('hasStateFor').hasStateFor(ref);
  }

  @override
  T read<T>(Ref<T> ref) {
    return fetchStore('read').read(ref);
  }

  @override
  void write<T>(Variable<T> ref, T value) {
    return fetchStore('write').write(ref, value);
  }

  @override
  void update<T>(Variable<T> ref, Updater<T> update) {
    return fetchStore('update').update(ref, update);
  }

  @override
  void delete<T>(Ref<T> ref) {
    return fetchStore('delete').delete(ref);
  }

  Store fetchStore(String methodName) {
    assert(
      !element.debugDoingBuild,
      'The store.$methodName method cannot be called during build',
    );
    final store = element.store ?? StateStore.of(element, listen: false);
    return store;
  }
}
