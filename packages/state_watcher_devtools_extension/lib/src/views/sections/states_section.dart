import 'package:flutter/material.dart';
import 'package:state_watcher/state_watcher.dart';
import 'package:state_watcher_devtools_extension/src/global_state_logic.dart';
import 'package:state_watcher_devtools_extension/src/models.dart';
import 'package:state_watcher_devtools_extension/src/views/devtools_page_logic.dart';
import 'package:state_watcher_devtools_extension/src/views/widgets/dev_tools_clearable_text_field.dart';
import 'package:state_watcher_devtools_extension/src/views/widgets/named_icon.dart';
import 'package:state_watcher_devtools_extension/src/views/widgets/section.dart';

final _refCurrentNode = Provided<Node>.undefined();

final _refFilter = Provided((_) => '');

final _refNodeList = Computed(
  (watch) {
    final nodes = watch(refAllNodes).values;
    final filter = watch(_refFilter).toLowerCase();
    final trackDependencies = watch(refTrackDependencies);
    Iterable<Node> filteredNodes = nodes;

    if (filter != '') {
      filteredNodes =
          nodes.where((x) => x.debugName.toLowerCase().contains(filter));
    }

    if (trackDependencies) {
      final ids = watch(refSelectedNodeDependencyIds);
      if (ids.isNotEmpty) {
        filteredNodes = filteredNodes.where((x) => ids.contains(x.id));
      }
    }

    return filteredNodes.toList();
  },
);

class StatesSection extends StatelessWidget {
  const StatesSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Section(
      title: Row(
        children: [
          Text('States'),
          Spacer(),
          NodeCount(),
        ],
      ),
      child: _NodePanel(),
    );
  }
}

class _NodePanel extends StatelessWidget {
  const _NodePanel();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Expanded(
          child: _NodeList(),
        ),
        _Filter(),
      ],
    );
  }
}

class NodeCount extends WatcherStatelessWidget {
  const NodeCount({
    super.key,
  });

  static final _nodeCount = Computed((watch) => watch(_refNodeList).length);

  @override
  Widget build(BuildContext context, BuildStore store) {
    final count = store.watch(_nodeCount);
    return Text(
      '$count',
      style: const TextStyle(color: Colors.grey),
    );
  }
}

class _NodeList extends WatcherStatelessWidget {
  const _NodeList();

  @override
  Widget build(BuildContext context, BuildStore store) {
    final nodes = store.watch(_refNodeList);

    return ListView.builder(
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        final node = nodes[index];
        return StateStore(
          overrides: {
            _refCurrentNode.overrideWithValue(node),
          },
          child: const _NodeItem(),
        );
      },
    );
  }
}

class _Filter extends WatcherStatelessWidget {
  const _Filter();

  @override
  Widget build(BuildContext context, BuildStore store) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        height: 48,
        child: DevToolsClearableTextField(
          hintText: 'Filter',
          onChanged: (value) {
            store.write(_refFilter, value);
          },
        ),
      ),
    );
  }
}

final _refIsSelectedNode = Computed((watch) {
  final node = watch(_refCurrentNode);
  final selectedNodeId = watch(refSelectedNodeId);
  return node.id == selectedNodeId;
});

class _NodeItem extends WatcherStatelessWidget {
  const _NodeItem();

  @override
  Widget build(BuildContext context, BuildStore store) {
    final node = store.watch(_refCurrentNode);
    final isSelected = store.watch(_refIsSelectedNode);

    return ListTile(
      dense: true,
      selected: isSelected,
      leading: const _RefIcon(),
      title: const _RefTileTitle(),
      onTap: () {
        store.read(refDevtoolsPageLogic).selectNode(node);
      },
    );
  }
}

class _RefIcon extends WatcherStatelessWidget {
  const _RefIcon();

  static final _typeToNamedIcon = {
    for (NodeType value in NodeType.values)
      value: NamedIcon(
        name: value.letter,
        color: value.color,
      ),
  };

  static final _refIcon = Computed(
    (watch) {
      final nodeType = watch(_refCurrentNode).nodeType;
      return _typeToNamedIcon[nodeType]!;
    },
  );

  @override
  Widget build(BuildContext context, BuildStore store) {
    final icon = store.watch(_refIcon);
    return icon;
  }
}

class _RefTileTitle extends WatcherStatelessWidget {
  const _RefTileTitle();

  static final _refNodeId = Computed(
    (watch) {
      final id = watch(_refCurrentNode).id;
      return '#$id';
    },
  );

  @override
  Widget build(BuildContext context, BuildStore store) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            store.watch(refNodeTitle(_refCurrentNode)),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          store.watch(_refNodeId),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
