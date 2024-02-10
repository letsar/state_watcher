import 'package:flutter/widgets.dart';
import 'package:state_watcher/src/core/build_store.dart';
import 'package:state_watcher/src/widgets/watcher_stateless_widget.dart';

/// Signature for a function to build a widget when the state changes.
typedef WatcherWidgetBuilder = Widget Function(
  BuildContext context,
  BuildStore store,
);

/// A widget which rebuilds its [builder] when the states associated to the
/// refs observed in it, changes
class WatcherBuilder extends WatcherStatelessWidget {
  /// Creates a new [WatcherBuilder].
  const WatcherBuilder({
    super.key,
    this.debugName,
    required this.builder,
  });

  @override
  final String? debugName;

  /// Builds the widget.
  final WatcherWidgetBuilder builder;

  @override
  Widget build(BuildContext context, BuildStore store) {
    return builder(context, store);
  }
}
