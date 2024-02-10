import 'dart:convert';
import 'dart:developer' as developer;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:state_watcher/src/core/build_store.dart';
import 'package:state_watcher/src/core/state_observer.dart';

import 'disposable.dart';

part 'state_inspector.dart';
part 'state_logic.dart';
part 'store_node.dart';

/// Signature for determining whether [a] and [b] are different.
typedef AreDifferent<T> = bool Function(T a, T b);

/// Represents an argument of a [Ref].
abstract class RefArg {
  /// Call [cleanup] when the state is no longer used.
  ///
  /// Any subsequent call to [onDispose] will replace the previous [cleanup]
  /// callback.
  void onDispose(VoidCallback cleanup);
}

/// Objects allowing to read the value of other [Ref]s.
abstract class Reader extends RefArg {
  /// Reads the value of another [Ref].
  X call<X>(Ref<X> ref);
}

/// Object allowing to watch and unwatch other [Ref]s.
abstract class Watcher<T> extends RefArg {
  /// Watches the value of [ref].
  X call<X>(Ref<X> ref);

  /// Unwatches the value of [ref].
  void cancel<X>(Ref<X> ref);

  /// Updates the state associated with the [Computed] using the [update]
  /// callback.
  ///
  /// Must be called once the first value has been computed, otherwise it will
  /// throw an error.
  void it(Updater<T> update);
}

/// Contains metadada about a [Ref].
class Metadata {
  /// Creates a new [Metadata].
  const Metadata({
    String? debugName,
    required this.refType,
    required this.valueType,
  })  : debugName = debugName ?? '$refType<$valueType>',
        isCustomName = debugName != null;

  /// The object used to identify this [Ref] in debug logs.
  final String debugName;

  /// The type of the [Ref].
  final String refType;

  /// The type of the value of the [Ref].
  final String valueType;

  /// Whether the [debugName] was provided by the user.
  final bool isCustomName;

  @override
  String toString() {
    return debugName;
  }
}

/// Represents the reference of a bit of state.
sealed class Ref<T> {
  /// Creates a new [Ref].
  const Ref({
    required this.id,
    required this.metadata,
    bool? autoDispose,
    AreDifferent<T>? updateShouldNotify,
    required this.global,
  })  : autoDispose = autoDispose ?? false,
        updateShouldNotify = updateShouldNotify ?? _defaultUpdateShouldNotify;

  /// Uniquely identifies this [Ref].
  final Object id;

  /// Metadata about this [Ref].
  final Metadata metadata;

  /// Whether the associated bit of state should be deleted when it is no longer
  /// used.
  ///
  /// Defaults to `false` for [Provided] and `true` for [Computed].
  final bool autoDispose;

  /// The function used to determine whether an update should refresh dependents.
  final AreDifferent<T> updateShouldNotify;

  /// Indicates whether this [Ref] should be stored in the root store or in the
  /// nearest one.
  final bool global;

  /// We need to create the node from the ref because we want to keep the type
  /// [T]. Otherwise we would get the type passed to the method used to create
  /// the node.
  Node<T> _createNode(StoreNode store);

  /// The name used in debugging tools to identify this [Ref].
  String get debugName => metadata.debugName;

  @override
  String toString() {
    return debugName;
  }
}

bool _defaultUpdateShouldNotify<T>(T a, T b) {
  return !const DeepCollectionEquality().equals(a, b);
}

/// A bit of state provided by the developper, that can be read from and written
/// to.
class Provided<T> extends Ref<T> {
  /// Creates a reference to a state which will be created later using the
  /// [create] function.
  ///
  /// The [create] function has a [read] parameter which can be used to read
  /// other states.
  Provided(
    T Function(Reader read) create, {
    String? debugName,
    bool? autoDispose,
    AreDifferent<T>? updateShouldNotify,
  }) : this._fromMetadata(
          create,
          metadata: Metadata(
            refType: 'Provided',
            valueType: '$T',
            debugName: debugName,
          ),
          autoDispose: autoDispose,
          updateShouldNotify: updateShouldNotify,
        );

  /// Creates a new [Provided] which undefined value.
  ///
  /// This is useful when you want to create a [Provided] that will be defined
  /// later, through an override in a store.
  Provided.undefined({
    String? debugName,
    bool? autoDispose,
    AreDifferent<T>? updateShouldNotify,
  }) : this(
          _undefinedProvided,
          debugName: debugName,
          autoDispose: autoDispose,
          updateShouldNotify: updateShouldNotify,
        );

  Provided._fromMetadata(
    T Function(Reader read) create, {
    required super.metadata,
    super.autoDispose,
    super.updateShouldNotify,
  })  : _create = create,
        super(id: metadata, global: true);

  /// Creates a new [Provided] with the given value, used to override the
  /// value of this [Provided] in a store.
  Provided<T> overrideWithValue(T value) {
    return Provided._fromMetadata(
      (_) => value,
      metadata: metadata,
      autoDispose: autoDispose,
      updateShouldNotify: updateShouldNotify,
    );
  }

  /// Creates a new [Provided] with the given creation funciton, used to
  /// override the creation of this [Provided] in a store.
  Provided<T> overrideWith(T Function(Reader read) create) {
    return Provided._fromMetadata(
      create,
      metadata: metadata,
      autoDispose: autoDispose,
      updateShouldNotify: updateShouldNotify,
    );
  }

  T Function(Reader read) _create;

  @override
  Node<T> _createNode(StoreNode store) {
    return ProvidedNode<T>(this, store);
  }
}

/// A parameterized bit of state that is derived from other states.
class ComputedWithParameterBuilder<T, P extends Object> {
  ComputedWithParameterBuilder._(
    this._compute,
    String? debugName,
    this._updateShouldNotify,
    this._global,
  ) : _metadata = Metadata(
          refType: 'Computed',
          valueType: '$T',
          debugName: debugName,
        );

  final Metadata _metadata;
  final AreDifferent<T>? _updateShouldNotify;
  final T Function(Watcher<T> watch, P parameter) _compute;
  final bool _global;

  /// Creates a new [Computed] with the given [parameter].
  Computed<T> call(P parameter) {
    return Computed._fromIdAndMetadata(
      (watch) => _compute(watch, parameter),
      id: _ComputedWithParameterBuilderId(parameter, _metadata),
      metadata: _metadata,
      autoDispose: true,
      updateShouldNotify: _updateShouldNotify,
      global: _global,
    );
  }
}

@immutable
class _ComputedWithParameterBuilderId<P> {
  const _ComputedWithParameterBuilderId(this.parameter, this.metadata);

  final P parameter;
  final Metadata metadata;

  @override
  int get hashCode => Object.hash(parameter, metadata);

  @override
  bool operator ==(Object other) {
    return identical(other, this) ||
        (other is _ComputedWithParameterBuilderId &&
            parameter == other.parameter &&
            metadata == other.metadata);
  }

  @override
  String toString() {
    return '$metadata($parameter)';
  }
}

/// A bit of state that is derived from other states.
class Computed<T> extends Ref<T> {
  /// Creates a reference to a state which will be created later using the
  /// [compute] function.
  ///
  /// The [compute] function has a [watch] parameter which can be used to watch
  /// other states.
  ///
  /// The [compute] function is called again when any of the states it watches
  /// changes and the resulting value is used to update the state associated
  /// with this [Computed].
  Computed(
    T Function(Watcher<T> watch) compute, {
    String? debugName,
    bool autoDispose = true,
    AreDifferent<T>? updateShouldNotify,
    bool global = false,
  }) : this._(
          compute,
          debugName: debugName,
          autoDispose: autoDispose,
          updateShouldNotify: updateShouldNotify,
          global: global,
        );

  Computed._(
    T Function(Watcher<T> watch) compute, {
    String? debugName,
    bool autoDispose = true,
    AreDifferent<T>? updateShouldNotify,
    bool global = false,
  }) : this._fromMetadata(
          compute,
          metadata: Metadata(
            refType: 'Computed',
            valueType: '$T',
            debugName: debugName,
          ),
          autoDispose: autoDispose,
          updateShouldNotify: updateShouldNotify,
          global: global,
        );

  Computed._fromMetadata(
    T Function(Watcher<T> watch) compute, {
    required super.metadata,
    required super.autoDispose,
    required super.updateShouldNotify,
    required super.global,
  })  : _compute = compute,
        super(id: metadata);

  Computed._fromIdAndMetadata(
    T Function(Watcher<T> watch) compute, {
    required super.id,
    required super.metadata,
    required super.autoDispose,
    required super.updateShouldNotify,
    required super.global,
  }) : _compute = compute;

  final T Function(Watcher<T> watch) _compute;

  @override
  Node<T> _createNode(StoreNode store) {
    return ComputedNode<T>(this, store);
  }

  /// Creates an object that can be used to create a [Computed] with a
  /// parameter.
  static ComputedWithParameterBuilder<T, P> withParameter<T, P extends Object>(
    T Function(Watcher<T> watch, P parameter) compute, {
    String? debugName,
    AreDifferent<T>? updateShouldNotify,
    bool global = false,
  }) {
    return ComputedWithParameterBuilder<T, P>._(
      compute,
      debugName,
      updateShouldNotify,
      global,
    );
  }
}

@internal
class Observed extends Ref<ObservedNode> {
  Observed(
    VoidCallback onDependencyChanged, {
    ObservedLocation? location,
    String? debugName,
    AreDifferent<void>? updateShouldNotify,
  }) : this._fromMetadata(
          onDependencyChanged: onDependencyChanged,
          location: location,
          metadata: Metadata(
            refType: 'Observed',
            valueType: 'void',
            debugName: debugName,
          ),
          updateShouldNotify: updateShouldNotify,
        );

  Observed._fromMetadata({
    required this.onDependencyChanged,
    required this.location,
    required super.metadata,
    required super.updateShouldNotify,
  }) : super(id: metadata, global: false);

  final VoidCallback onDependencyChanged;
  final ObservedLocation? location;

  @override
  Node<ObservedNode> _createNode(StoreNode store) {
    return ObservedNode(this, store);
  }
}

@internal
class ObservedLocation {
  const ObservedLocation({
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

Never _undefinedProvided(Reader read) {
  throw StateError('Undefined provided');
}

/// Signature for updating a state.
typedef Updater<T> = T Function(T oldValue);
