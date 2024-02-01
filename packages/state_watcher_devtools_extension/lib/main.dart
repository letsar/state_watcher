import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';
import 'package:state_watcher/state_watcher.dart';
import 'package:state_watcher_devtools_extension/src/views/devtools_page.dart';

void main() {
  runApp(const StateWatcherDevToolsExtension());
}

class StateWatcherDevToolsExtension extends StatelessWidget {
  const StateWatcherDevToolsExtension({super.key});

  @override
  Widget build(BuildContext context) {
    return const DevToolsExtension(
      child: StateStore(
        child: DevToolsPage(),
      ),
    );
  }
}
