import 'dart:async';

import 'package:devtools_app_shared/ui.dart';
import 'package:flutter/material.dart';
import 'package:state_watcher/state_watcher.dart';
import 'package:state_watcher_devtools_extension/src/global_state_logic.dart';
import 'package:state_watcher_devtools_extension/src/views/sections/details_section.dart';
import 'package:state_watcher_devtools_extension/src/views/sections/logs_section.dart';
import 'package:state_watcher_devtools_extension/src/views/sections/states_section.dart';

class DevToolsPage extends WatcherStatefulWidget {
  const DevToolsPage({
    super.key,
  });

  @override
  State<DevToolsPage> createState() => _DevToolsPageState();
}

class _DevToolsPageState extends State<DevToolsPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  BuildStore initStore() {
    unawaited(store.read(refGlobalState).init());
    return store;
  }

  @override
  void dispose() {
    store.delete(refGlobalState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final axis = Split.axisFor(context, 0.85);
    return Split(
      axis: axis,
      initialFractions: const [0.33, 0.67],
      minSizes: const [130, 200],
      children: [
        const StatesSection(),
        Split(
          axis: Axis.vertical,
          initialFractions: const [0.25, 0.75],
          minSizes: const [100, 100],
          children: const [
            DetailsSection(),
            LogsSection(),
          ],
        ),
      ],
    );
  }
}
