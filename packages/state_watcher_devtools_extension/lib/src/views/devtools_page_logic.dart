import 'package:state_watcher/state_watcher.dart';
import 'package:state_watcher_devtools_extension/src/global_state_logic.dart';
import 'package:state_watcher_devtools_extension/src/models.dart';
import 'package:vm_service/vm_service.dart';

final refSelectedNodeValue = Variable<InstanceRef?>((_) => null);
final refSelectedNodeId = Variable<String?>((_) => null);
final refSelectedNode = Computed((watch) {
  final id = watch(refSelectedNodeId);
  return id == null ? null : watch(refAllNodes)[id];
});
final refSelectedNodeDependencyIds = Computed((watch) {
  final id = watch(refSelectedNodeId);
  if (id == null) {
    return const <String>{};
  }
  final allNodes = watch(refAllNodes);
  final selectedNode = allNodes[id];
  if (selectedNode == null) {
    // Should not happen.
    return const <String>{};
  }
  final result = <String>{id};
  selectedNode.addDependencyIdsTo(result, allNodes);
  return result;
});
final refNodeTitle = Computed.withParameter(
  (watch, Variable<Node> nodeRef) {
    final node = watch(nodeRef);

    if (node.nodeType != NodeType.watcher) {
      return node.isCustomName ? node.debugName : node.valueType;
    }

    return node.debugName.replaceFirst('Watcher[', '').replaceFirst(']', '');
  },
);

final refTrackDependencies = Variable((_) => false);
final refDevtoolsPageLogic = Variable((_) => DevToolsPageLogic());

class DevToolsPageLogic with StateLogic {
  DevToolsPageLogic();

  void selectNode(Node node) {
    update(refSelectedNodeId, (id) {
      if (id == node.id) {
        return null;
      } else {
        return node.id;
      }
    });
  }
}
