import 'package:devtools_app_shared/ui.dart';
import 'package:flutter/material.dart';
import 'package:state_watcher/state_watcher.dart';
import 'package:state_watcher_devtools_extension/src/models.dart';
import 'package:state_watcher_devtools_extension/src/views/devtools_page_logic.dart';
import 'package:state_watcher_devtools_extension/src/views/widgets/section.dart';

final _refCurrentNode = Variable<Node>.undefined();

class DetailsSection extends StatelessWidget {
  const DetailsSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Section(
      title: _DetailsSectionTitle(),
      actions: [
        _ToggleTrackingDependenciesButton(),
      ],
      child: _SelectedNodePanel(),
    );
  }
}

class _ToggleTrackingDependenciesButton extends WatcherStatelessWidget {
  const _ToggleTrackingDependenciesButton();

  @override
  Widget build(BuildContext context, BuildScope scope) {
    final isSelected = scope.watch(refTrackDependencies);
    return DevToolsToggleButton(
      icon: Icons.lan_outlined,
      onPressed: () {
        scope.update(refTrackDependencies, (oldValue) => !oldValue);
      },
      isSelected: isSelected,
      outlined: false,
      message: isSelected ? 'Do not track dependencies' : 'Track dependencies',
    );
  }
}

class _DetailsSectionTitle extends WatcherStatelessWidget {
  const _DetailsSectionTitle();

  @override
  Widget build(BuildContext context, BuildScope scope) {
    final node = scope.watch(refSelectedNode);

    if (node == null) {
      return const Text('Details');
    } else {
      return StateScope(
        overrides: {
          _refCurrentNode.overrideWithValue(node),
        },
        child: const _NodeName(),
      );
    }
  }
}

class _SelectedNodePanel extends WatcherStatelessWidget {
  const _SelectedNodePanel();

  @override
  Widget build(BuildContext context, BuildScope scope) {
    final node = scope.watch(refSelectedNode);

    return node == null
        ? const Center(
            child: Text(
              'Select an item in the States panel to view its details',
            ),
          )
        : StateScope(
            overrides: {
              _refCurrentNode.overrideWithValue(node),
            },
            child: const _NodeDetails(),
          );
  }
}

class _NodeDetails extends StatelessWidget {
  const _NodeDetails();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ValueOrLocation(),
          ],
        ),
      ),
    );
  }
}

class _NodeName extends WatcherStatelessWidget {
  const _NodeName();

  static final _refNodeId = Computed(
    (watch) {
      final id = watch(_refCurrentNode).id;
      return '#$id';
    },
  );

  @override
  Widget build(BuildContext context, BuildScope scope) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _Chip(),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            scope.watch(refNodeTitle(_refCurrentNode)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          scope.watch(_refNodeId),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 4),
        const _Scope(),
      ],
    );
  }
}

class _Chip extends WatcherStatelessWidget {
  const _Chip();

  static final _nodeType = Computed(
    (watch) {
      return watch(_refCurrentNode).nodeType;
    },
  );

  @override
  Widget build(BuildContext context, BuildScope scope) {
    final nodeType = scope.watch(_nodeType);
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        color: nodeType.color,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          nodeType.name,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 12,
            leadingDistribution: TextLeadingDistribution.even,
          ),
        ),
      ),
    );
  }
}

class _ValueOrLocation extends WatcherStatelessWidget {
  const _ValueOrLocation();

  static final _refIsWatcher = Computed((watch) {
    final node = watch(_refCurrentNode);
    return node.nodeType == NodeType.watcher;
  });

  @override
  Widget build(BuildContext context, BuildScope scope) {
    final isWatcher = scope.watch(_refIsWatcher);

    return isWatcher ? const _Location() : const _Value();
  }
}

class _Value extends WatcherStatelessWidget {
  const _Value();

  static final _refValue = Computed(
    (watch) {
      final node = watch(_refCurrentNode);
      return node.value;
    },
  );

  @override
  Widget build(BuildContext context, BuildScope scope) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Value:'),
        Text(
          scope.watch(_refValue),
        ),
      ],
    );
  }
}

class _Location extends WatcherStatelessWidget {
  const _Location();

  static final _refLocation = Computed((watch) {
    final node = watch(_refCurrentNode);
    return node.location ?? '';
  });

  @override
  Widget build(BuildContext context, BuildScope scope) {
    final location = scope.watch(_refLocation);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Location:'),
        Text(location),
      ],
    );
  }
}

class _Scope extends WatcherStatelessWidget {
  const _Scope();

  static final _refScopeId = Computed(
    (watch) {
      final node = watch(_refCurrentNode);
      return node.scopeId;
    },
  );

  @override
  Widget build(BuildContext context, BuildScope scope) {
    final scopeId = scope.watch(_refScopeId);
    return Text(
      'Scope: #$scopeId',
      style: const TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
    );
  }
}
