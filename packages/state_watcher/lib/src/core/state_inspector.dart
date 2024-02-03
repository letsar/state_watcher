part of 'refs.dart';

const _prefix = 'ext.state_watcher';

// coverage:ignore-start
@internal
class StateInspector {
  StateInspector._();

  static StateInspector instance = kDebugMode
      ? StateInspector._()
      : throw UnsupportedError(
          'Cannot use StateInspector outside of debug mode.',
        );

  final Map<String, Node<Object?>> _nodes = {};
  bool _initialized = false;

  bool _canPostUpdateEvent = true;

  void _init() {
    if (_initialized) {
      return;
    }
    developer.registerExtension(
      '$_prefix.getNodes',
      (method, parameters) async {
        final nodeList = _nodes.values.map((e) => e.toJson()).toList();
        // The final result needs to be a map.
        final json = jsonEncode({'nodes': nodeList});
        final result = developer.ServiceExtensionResponse.result(json);
        return result;
      },
    );
    _initialized = true;
  }

  void mutePostUpdateEvent(void Function() callback) {
    _canPostUpdateEvent = false;
    callback();
    _canPostUpdateEvent = true;
  }

  void didStateCreated<T>(Node<T> node) {
    _nodes[node.debugId] = node;
    _debugPostNodeEvent('didStateCreated', node);
  }

  void didStateUpdated<T>(Node<T> node) {
    if (_canPostUpdateEvent) {
      _debugPostNodeEvent('didStateUpdated', node);
    }
  }

  void didStateDeleted<T>(Node<T> node) {
    _nodes.remove(node.debugId);
    _debugPostNodeEvent('didStateDeleted', node);
  }

  void _debugPostNodeEvent<T>(String method, Node<T> node) {
    _debugPostEvent(method, () => node.toJson());
  }

  void _debugPostEvent(
    String method,
    Map<Object?, Object?> Function() event,
  ) {
    _init();
    if (developer.extensionStreamHasListener) {
      developer.postEvent('$_prefix.$method', event());
    }
  }
}
// coverage:ignore-end
