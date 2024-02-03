import 'dart:ui';

enum NodeType {
  variable('V', 'Variable', Color(0xFFd0f4de)),
  computed('C', 'Computed', Color(0xFFa9def9)),
  watcher('W', 'Watcher', Color(0xFFfcf6bd));

  const NodeType(this.letter, this.name, this.color);

  final String letter;
  final String name;
  final Color color;
}

class Node {
  Node({
    required this.id,
    required this.debugName,
    required this.isCustomName,
    required this.refType,
    required this.valueType,
    required this.storeId,
    required this.dependencyIds,
    required this.value,
    required this.location,
  }) : nodeType = _nodeTypeFromRefTypeAndLocation(refType);

  final String id;
  final bool isCustomName;
  final String refType;
  final String valueType;
  final String debugName;
  final String storeId;
  final Set<String> dependencyIds;
  final String value;
  final String? location;
  final NodeType nodeType;

  Node copyWithValue(String value) {
    return Node(
      id: id,
      debugName: debugName,
      isCustomName: isCustomName,
      refType: refType,
      valueType: valueType,
      storeId: storeId,
      dependencyIds: dependencyIds,
      value: value,
      location: location,
    );
  }

  Node copyWithDependencies(Set<String> dependencyIds) {
    return Node(
      id: id,
      debugName: debugName,
      isCustomName: isCustomName,
      refType: refType,
      valueType: valueType,
      storeId: storeId,
      dependencyIds: dependencyIds,
      value: value,
      location: location,
    );
  }

  void addDependencyIdsTo(Set<String> dependencyIds, Map<String, Node> nodes) {
    for (final id in this.dependencyIds) {
      final node = nodes[id];
      if (node != null) {
        dependencyIds.add(id);
        node.addDependencyIdsTo(dependencyIds, nodes);
      }
    }
  }
}

NodeType _nodeTypeFromRefTypeAndLocation(String refType) {
  return switch (refType) {
    'Variable' => NodeType.variable,
    'Observed' => NodeType.watcher,
    _ => NodeType.computed,
  };
}

class Store {
  const Store({
    required this.id,
    required this.debugName,
  });

  final String id;
  final String debugName;
}

class Location {
  const Location({
    required this.file,
    required this.line,
    required this.column,
  });

  final String file;
  final int line;
  final int column;

  @override
  String toString() {
    return '$file:$line:$column';
  }
}

enum LogType {
  created('C', 'Created', Color(0xFF2a9d8f)),
  updated('U', 'Updated', Color(0xFFe9c46a)),
  deleted('D', 'Deleted', Color(0xFFe76f51));

  const LogType(this.letter, this.name, this.color);

  final String letter;
  final String name;
  final Color color;
}

class LogItem {
  const LogItem({
    required this.nodeId,
    required this.logType,
    required this.message,
  });

  final String nodeId;
  final LogType logType;
  final String message;
}
