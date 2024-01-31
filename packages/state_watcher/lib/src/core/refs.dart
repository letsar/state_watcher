import 'dart:convert';
import 'dart:developer' as developer;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:state_watcher/src/core/state_observer.dart';

import 'disposable.dart';

part 'scope_context.dart';
part 'state_inspector.dart';
part 'state_logic.dart';

/// Signature for determining whether [a] and [b] are different.
typedef AreDifferent<T> = bool Function(T a, T b);

/// Signature for getting the value of a [Ref].
typedef Reader = T Function<T>(Ref<T> ref);

/// Contains metadada about a [Ref].
class Metadata {
  /// Creates a new [Metadata].
  const Metadata({
    Object? debugName,
    required this.refType,
    required this.valueType,
  })  : debugName = debugName ?? '$refType<$valueType>',
        isCustomName = debugName != null;

  /// The object used to identify this [Ref] in debug logs.
  final Object debugName;

  /// The type of the [Ref].
  final String refType;

  /// The type of the value of the [Ref].
  final String valueType;

  /// Whether the [debugName] was provided by the user.
  final bool isCustomName;

  @override
  String toString() {
    return debugName.toString();
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
  })  : autoDispose = autoDispose ?? false,
        updateShouldNotify = updateShouldNotify ?? _defaultUpdateShouldNotify;

  /// Uniquely identifies this [Ref].
  final Object id;

  /// Metadata about this [Ref].
  final Metadata metadata;

  /// Whether the associated bit of state should be deleted when it is no longer
  /// used.
  ///
  /// Defaults to `false` for [Variable] and `true` for [Computed].
  final bool autoDispose;

  /// The function used to determine whether an update should refresh dependents.
  final AreDifferent<T> updateShouldNotify;

  /// We need to create the node from the ref because we want to keep the type
  /// [T]. Otherwise we would get the type passed to the method used to create
  /// the node.
  Node<T> _createNode(ScopeContext scope);

  /// The name used in debugging tools to identify this [Ref].
  String get debugName => metadata.debugName.toString();

  @override
  String toString() {
    return debugName;
  }
}

bool _defaultUpdateShouldNotify<T>(T a, T b) {
  return !const DeepCollectionEquality().equals(a, b);
}

/// A bit of state that can be read from and written to.
class Variable<T> extends Ref<T> {
  /// Creates a reference to a state which will be created later using the
  /// [create] function.
  ///
  /// The [create] function has a [read] parameter which can be used to read
  /// other states.
  Variable(
    T Function(Reader read) create, {
    String? debugName,
    bool? autoDispose,
    AreDifferent<T>? updateShouldNotify,
  }) : this._fromMetadata(
          create,
          metadata: Metadata(
            refType: 'Variable',
            valueType: '$T',
            debugName: debugName,
          ),
          autoDispose: autoDispose,
          updateShouldNotify: updateShouldNotify,
        );

  /// Creates a new [Variable] which undefined value.
  ///
  /// This is useful when you want to create a [Variable] that will be defined
  /// later, through an override in a scope.
  Variable.undefined({
    String? debugName,
    bool? autoDispose,
    AreDifferent<T>? updateShouldNotify,
  }) : this(
          _undefinedVariable,
          debugName: debugName,
          autoDispose: autoDispose,
          updateShouldNotify: updateShouldNotify,
        );

  Variable._fromMetadata(
    T Function(Reader read) create, {
    required super.metadata,
    super.autoDispose,
    super.updateShouldNotify,
  })  : _create = create,
        super(id: metadata);

  /// Creates a new [Variable] with the given value, used to override the
  /// value of this [Variable] in a scope.
  Variable<T> overrideWithValue(T value) {
    return Variable._fromMetadata(
      (_) => value,
      metadata: metadata,
      autoDispose: autoDispose,
      updateShouldNotify: updateShouldNotify,
    );
  }

  /// Creates a new [Variable] with the given creation funciton, used to
  /// override the creation of this [Variable] in a scope.
  Variable<T> overrideWith(T Function(Reader read) create) {
    return Variable._fromMetadata(
      create,
      metadata: metadata,
      autoDispose: autoDispose,
      updateShouldNotify: updateShouldNotify,
    );
  }

  T Function(Reader read) _create;

  @override
  Node<T> _createNode(ScopeContext scope) {
    return VariableNode<T>(this, scope);
  }
}

/// A parameterized bit of state that is derived from other states.
class ComputedWithParameterBuilder<T, P extends Object> {
  ComputedWithParameterBuilder._(
    this._compute,
    String? debugName,
    this._updateShouldNotify,
  ) : _metadata = Metadata(
          refType: 'Computed',
          valueType: '$T',
          debugName: debugName,
        );

  final Metadata _metadata;
  final AreDifferent<T>? _updateShouldNotify;
  final T Function(Reader watch, P parameter) _compute;

  /// Creates a new [Computed] with the given [parameter].
  Computed<T> call(P parameter) {
    return Computed._fromIdAndMetadata(
      (watch) => _compute(watch, parameter),
      id: _ComputedWithParameterBuilderId(parameter, _metadata),
      metadata: _metadata,
      autoDispose: true,
      updateShouldNotify: _updateShouldNotify,
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
    T Function(Reader watch) compute, {
    Object? debugName,
    bool autoDispose = true,
    AreDifferent<T>? updateShouldNotify,
  }) : this._(
          compute,
          debugName: debugName,
          autoDispose: autoDispose,
          updateShouldNotify: updateShouldNotify,
        );

  Computed._(
    T Function(Reader watch) compute, {
    Object? debugName,
    bool autoDispose = true,
    AreDifferent<T>? updateShouldNotify,
  }) : this._fromMetadata(
          compute,
          metadata: Metadata(
            refType: 'Computed',
            valueType: '$T',
            debugName: debugName,
          ),
          autoDispose: autoDispose,
          updateShouldNotify: updateShouldNotify,
        );

  Computed._fromMetadata(
    T Function(Reader watch) compute, {
    required super.metadata,
    required super.autoDispose,
    required super.updateShouldNotify,
  })  : _compute = compute,
        super(id: metadata);

  Computed._fromIdAndMetadata(
    T Function(Reader watch) compute, {
    required super.id,
    required super.metadata,
    required super.autoDispose,
    required super.updateShouldNotify,
  }) : _compute = compute;

  final T Function(Reader watch) _compute;

  @override
  Node<T> _createNode(ScopeContext scope) {
    return ComputedNode<T>(this, scope);
  }

  /// Creates an object that can be used to create a [Computed] with a
  /// parameter.
  static ComputedWithParameterBuilder<T, P> withParameter<T, P extends Object>(
    T Function(Reader watch, P parameter) compute, {
    String? debugName,
    AreDifferent<T>? updateShouldNotify,
  }) {
    return ComputedWithParameterBuilder<T, P>._(
      compute,
      debugName,
      updateShouldNotify,
    );
  }
}

Never _undefinedVariable(Reader read) {
  throw StateError('Undefined variable');
}

/// Signature for updating a state.
typedef Updater<T> = T Function(T oldValue);

/// A container of states.
abstract class Scope {
  /// Indicates whether [ref] has a value inside this [Scope].
  bool hasStateFor<T>(Ref<T> ref);

  /// Reads the value of [ref] from this [Scope].
  T read<T>(Ref<T> ref);

  /// Writes the [value] associated with [ref] in this [Scope].
  void write<T>(Variable<T> ref, T value);

  /// Updates the value associated with [ref] in this [Scope] using the
  /// [updater].
  void update<T>(Variable<T> ref, Updater<T> update);

  /// Deletes the value associated with [ref] from this [Scope].
  void delete<T>(Ref<T> ref);
}
