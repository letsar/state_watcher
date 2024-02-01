import 'dart:async';

import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:state_watcher/state_watcher.dart' hide Store;
import 'package:state_watcher_devtools_extension/src/models.dart';

const _prefix = 'ext.state_watcher';

final refAllNodes = Variable((_) => <String, Node>{});

final refAllStores = Variable((_) => <String, Store>{});

final refAllLogs = Variable((_) => <LogItem>[]);

final refGlobalState = Variable((_) => GlobalStateLogic());

class GlobalStateLogic with StateLogic {
  GlobalStateLogic();

  late StreamSubscription<Object?> _subscription;

  Future<void> init() async {
    // ignore: cancel_subscriptions
    final subscription = serviceManager.service?.onExtensionEvent
        .where((e) => e.extensionKind?.startsWith(_prefix) ?? false)
        .listen((event) {
      final method = event.extensionKind?.substring(_prefix.length + 1) ?? '';
      final data = event.extensionData?.data ?? const {};
      _handleData(method, data);
    });
    if (subscription != null) {
      _subscription = subscription;
    }

    // Fetch the initial state.
    await refreshNodes();
  }

  Future<void> refreshNodes() async {
    try {
      final response = await serviceManager.callServiceExtensionOnMainIsolate(
        '$_prefix.getNodes',
      );
      final items = (response.json?['nodes'] as List<Object?>?) ?? [];
      final nodes = <String, Node>{};
      final stores = <String, Store>{};
      for (final item in items) {
        final map = item! as Map<String, Object?>;
        final node = _createNodeFromData(map);
        final storeId = node.storeId;
        stores.putIfAbsent(
          storeId,
          () => Store(
            debugName: map['storeDebugName']! as String,
            id: storeId,
          ),
        );
        nodes[node.id] = node;
      }
      write(refAllNodes, nodes);
      write(refAllStores, stores);
    } catch (e) {
      debugPrint('Error fetching nodes: $e');
    }
  }

  void _handleData(String method, Map<String, Object?> data) {
    switch (method) {
      case 'didStateCreated':
        _didStateCreated(data);
      case 'didStateUpdated':
        _didStateUpdated(data);
      case 'didStateDeleted':
        _didStateDeleted(data);
      default:
        break;
    }
  }

  void _didStateCreated(Map<String, Object?> data) {
    final node = _createNodeFromData(data);

    // Find the store.
    final storeId = node.storeId;
    final storeDebugName = data['storeDebugName']! as String;
    final allStores = Map<String, Store>.from(read(refAllStores));
    allStores.putIfAbsent(
      storeId,
      () => Store(id: storeId, debugName: storeDebugName),
    );
    write(refAllStores, allStores);
    final allNodes = Map<String, Node>.from(read(refAllNodes));
    allNodes[node.id] = node;
    write(refAllNodes, allNodes);
    _addLogItem(
      LogType.created,
      node.id,
      node.nodeType == NodeType.watcher
          ? node.debugName
          : '${node.debugName} with value: ${node.value}',
    );
  }

  void _didStateUpdated(Map<String, Object?> data) {
    final node = _createNodeFromData(data);
    final allNodes = Map<String, Node>.from(read(refAllNodes));
    final oldNode = allNodes[node.id];
    allNodes[node.id] = node;
    write(refAllNodes, allNodes);
    _addLogItem(
      LogType.updated,
      node.id,
      node.nodeType == NodeType.watcher
          ? node.debugName
          : '${node.debugName} from ${oldNode?.value} to ${node.value}',
    );
  }

  void _didStateDeleted(Map<String, Object?> data) {
    final node = _createNodeFromData(data);
    final allNodes = Map<String, Node>.from(read(refAllNodes));
    allNodes.remove(node.id);
    write(refAllNodes, allNodes);
    _addLogItem(LogType.deleted, node.id, node.debugName);
  }

  void _addLogItem(LogType logType, String nodeId, String message) {
    final newLogs = [
      LogItem(logType: logType, nodeId: nodeId, message: message),
      ...read(refAllLogs),
    ];
    write(refAllLogs, newLogs);
  }

  Node _createNodeFromData(Map<String, Object?> data) {
    final id = data['id']! as String;
    final debugName = data['debugName']! as String;
    final customName = data['customName']! as bool;
    final refType = data['refType']! as String;
    final valueType = data['valueType']! as String;
    final storeId = data['storeId']! as String;
    final dependencies =
        (data['dependencies']! as List<Object?>).cast<String>();
    final value = data['value']! as String;
    final file = data['file'] as String?;
    final line = data['line'] as int?;
    final column = data['column'] as int?;
    final location = file != null && line != null && column != null
        ? Location(file: file, line: line, column: column)
        : null;
    return Node(
      id: id,
      debugName: debugName,
      isCustomName: customName,
      refType: refType,
      valueType: valueType,
      storeId: storeId,
      dependencyIds: dependencies.toSet(),
      value: value,
      location: location?.toString(),
    );
  }

  @override
  void dispose() {
    // ignore: discarded_futures
    _subscription.cancel();
  }
}
