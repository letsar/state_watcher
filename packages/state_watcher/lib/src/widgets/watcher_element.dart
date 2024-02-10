import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:state_watcher/src/core/build_store.dart';
import 'package:state_watcher/src/core/refs.dart';
import 'package:state_watcher/src/widgets/state_store.dart';

@internal
mixin WatcherElement on ComponentElement {
  String? get debugName;

  late final BuildStore buildStore = _BuildStore(this);

  StoreNode? _store;
  StoreNode get store => _store ??= dependOnParentStore(this, listen: false);

  late final Observed observed = createObserved();

  Observed createObserved() {
    final location = fetchElementLocation();
    final effectiveDebugName =
        debugName ?? 'Watcher[${location?.name ?? toStringShort()}]';
    return Observed(
      onStateChanged,
      location: location,
      debugName: effectiveDebugName,
    );
  }

  void onStateChanged() {
    if (mounted) {
      markNeedsBuild();
    }
  }

  ObservedLocation? fetchElementLocation() {
    if (kDebugMode) {
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

          return ObservedLocation(
            name: 'Watcher[$name]',
            file: file,
            line: line,
            column: column,
          );
        }
      }
    }

    return null;
  }

  @override
  void activate() {
    super.activate();
    final newStore = dependOnParentStore(this, listen: false);
    if (newStore != store) {
      _store?.delete(observed);
      _store = newStore;
    }
  }

  @override
  void unmount() {
    _store?.delete(observed);
    super.unmount();
  }

  @override
  Widget build() {
    return store.read(observed).trackDependencyChanges(super.build);
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
    final store = element.store.read(element.observed);
    return store.watch(ref);
  }

  @override
  bool hasStateFor<T>(Ref<T> ref) {
    return fetchStore('hasStateFor').hasStateFor(ref);
  }

  @override
  int get stateCount => fetchStore('stateCount').stateCount;

  @override
  T read<T>(Ref<T> ref) {
    return fetchStore('read').read(ref);
  }

  @override
  void write<T>(Provided<T> ref, T value) {
    return fetchStore('write').write(ref, value);
  }

  @override
  void update<T>(Provided<T> ref, Updater<T> update) {
    return fetchStore('update').update(ref, update);
  }

  @override
  void delete<T>(Ref<T> ref) {
    return fetchStore('delete').delete(ref);
  }

  BuildStore fetchStore(String methodName) {
    assert(
      !element.debugDoingBuild,
      'The store.$methodName method cannot be called during build',
    );
    return element.store.read(element.observed);
  }
}
