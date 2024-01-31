import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:state_watcher/src/core/refs.dart';
import 'package:state_watcher/src/widgets/build_scope.dart';
import 'package:state_watcher/src/widgets/state_scope.dart';

@internal
mixin WatcherElement on ComponentElement {
  final Set<Ref<Object?>> _dependencies = {};
  String? get debugName;

  late final BuildScope buildScope = _BuildScope(this);

  ScopeContext? _scope;
  ScopeContext? get scope => _scope;
  set scope(ScopeContext? newScope) {
    if (newScope != _scope) {
      _scope?.delete(computed);
      _scope = newScope;
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
    scope = dependOnParentScope(this);
  }

  @override
  void unmount() {
    _dependencies.clear();
    _scope?.delete(computed);
    super.unmount();
  }

  @override
  Widget build() {
    // We need to clear the dependencies before building the widget in case we
    // have conditional dependencies.
    _dependencies.clear();
    final result = super.build();

    /// We need to read the computed value to register the dependencies.
    _scope?.refresh(computed);
    return result;
  }
}

class _BuildScope implements BuildScope {
  _BuildScope(this.element);

  final WatcherElement element;

  @override
  T watch<T>(Ref<T> ref) {
    assert(
      element.debugDoingBuild,
      'Cannot watch the state outside of the build method.',
    );
    final scope = element.scope ??= dependOnParentScope(element);
    element._dependencies.add(ref);
    return scope.read(ref);
  }

  @override
  bool hasStateFor<T>(Ref<T> ref) {
    return fetchScope('hasStateFor').hasStateFor(ref);
  }

  @override
  T read<T>(Ref<T> ref) {
    return fetchScope('read').read(ref);
  }

  @override
  void write<T>(Variable<T> ref, T value) {
    return fetchScope('write').write(ref, value);
  }

  @override
  void update<T>(Variable<T> ref, Updater<T> update) {
    return fetchScope('update').update(ref, update);
  }

  @override
  void delete<T>(Ref<T> ref) {
    return fetchScope('delete').delete(ref);
  }

  Scope fetchScope(String methodName) {
    assert(
      !element.debugDoingBuild,
      'The scope.$methodName method cannot be called during build',
    );
    final scope = element.scope ?? StateScope.of(element, listen: false);
    return scope;
  }
}
