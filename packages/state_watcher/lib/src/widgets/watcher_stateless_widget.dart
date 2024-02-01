import 'package:flutter/widgets.dart';
import 'package:state_watcher/src/widgets/build_store.dart';
import 'package:state_watcher/src/widgets/watcher_stateful_widget.dart';

/// A [StatelessWidget] which can be used to watch the changes of [Ref]s.
abstract class WatcherStatelessWidget extends WatcherStatefulWidget {
  /// Creates a new [WatcherStatelessWidget].
  const WatcherStatelessWidget({
    super.key,
  });

  @override
  State<WatcherStatelessWidget> createState() => _WatcherStatelessWidgetState();

  /// Builds the widget.
  @protected
  Widget build(BuildContext context, BuildStore store);
}

class _WatcherStatelessWidgetState extends State<WatcherStatelessWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.build(context, store);
  }
}
