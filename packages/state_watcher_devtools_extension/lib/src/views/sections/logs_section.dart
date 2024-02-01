import 'package:devtools_app_shared/ui.dart';
import 'package:flutter/material.dart';
import 'package:state_watcher/state_watcher.dart';
import 'package:state_watcher_devtools_extension/src/global_state_logic.dart';
import 'package:state_watcher_devtools_extension/src/models.dart';
import 'package:state_watcher_devtools_extension/src/views/devtools_page_logic.dart';
import 'package:state_watcher_devtools_extension/src/views/widgets/named_icon.dart';
import 'package:state_watcher_devtools_extension/src/views/widgets/section.dart';

final _refLogs = Computed((watch) {
  final selectedNodeId = watch(refSelectedNode)?.id;
  final allLogs = watch(refAllLogs);
  if (selectedNodeId == null) {
    return allLogs;
  }
  final ids = <String>{selectedNodeId};
  final shouldTrackDependencies = watch(refTrackDependencies);
  if (shouldTrackDependencies) {
    ids.addAll(watch(refSelectedNodeDependencyIds));
  }

  return allLogs.where((x) => ids.contains(x.nodeId)).toList();
});

final _refCurrentLog = Variable<LogItem>.undefined();

class LogsSection extends StatelessWidget {
  const LogsSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Section(
      title: Text('Logs'),
      actions: [
        _ClearLogsButton(),
      ],
      child: _LogPanel(),
    );
  }
}

class _LogPanel extends WatcherStatelessWidget {
  const _LogPanel();

  @override
  Widget build(BuildContext context, BuildStore store) {
    final logs = store.watch(_refLogs);
    return _LogViewer(
      logs: logs,
    );
  }
}

class _ClearLogsButton extends WatcherStatelessWidget {
  const _ClearLogsButton();

  @override
  Widget build(BuildContext context, BuildStore store) {
    return DevToolsButton.iconOnly(
      icon: Icons.clear,
      tooltip: 'Clear logs',
      outlined: false,
      onPressed: () {
        store.update(refAllLogs, (oldValue) => const []);
      },
    );
  }
}

class _LogViewer extends StatelessWidget {
  const _LogViewer({
    required this.logs,
  });

  final List<LogItem> logs;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      findChildIndexCallback: (key) {
        if (key is ValueKey<int>) {
          return key.value;
        }
        return null;
      },
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return StateStore(
          key: ValueKey(index),
          overrides: {
            _refCurrentLog.overrideWithValue(log),
          },
          child: const ListTile(
            dense: true,
            title: _LogItem(),
          ),
        );
      },
    );
  }
}

class _LogItem extends StatelessWidget {
  const _LogItem();

  @override
  Widget build(BuildContext context) {
    return const _Tooltip(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LogTypeIcon(),
          SizedBox(width: 4),
          _LogId(),
          SizedBox(width: 4),
          Flexible(child: _LogMessage()),
        ],
      ),
    );
  }
}

class _LogTypeIcon extends WatcherStatelessWidget {
  const _LogTypeIcon();

  static final _typeToNamedIcon = {
    for (LogType value in LogType.values)
      value: NamedIcon(
        name: value.letter,
        color: value.color,
      ),
  };

  static final _refIcon = Computed(
    (watch) {
      final logType = watch(_refCurrentLog).logType;
      return _typeToNamedIcon[logType]!;
    },
  );

  @override
  Widget build(BuildContext context, BuildStore store) {
    final icon = store.watch(_refIcon);
    return icon;
  }
}

class _LogId extends WatcherStatelessWidget {
  const _LogId();

  static final _refNodeId = Computed(
    (watch) {
      final id = watch(_refCurrentLog).nodeId;
      return '#$id';
    },
  );

  @override
  Widget build(BuildContext context, BuildStore store) {
    return Text(
      store.watch(_refNodeId),
      style: const TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
    );
  }
}

final _refLogMessage = Computed(
  (watch) {
    final log = watch(_refCurrentLog);
    return log.message;
  },
);

class _LogMessage extends WatcherStatelessWidget {
  const _LogMessage();

  @override
  Widget build(BuildContext context, BuildStore store) {
    final message = store.watch(_refLogMessage);
    return Text(
      message,
      style: const TextStyle(fontSize: 12),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _Tooltip extends WatcherStatelessWidget {
  const _Tooltip({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, BuildStore store) {
    final message = store.watch(_refLogMessage);
    return DevToolsTooltip(
      message: message,
      child: child,
    );
  }
}
