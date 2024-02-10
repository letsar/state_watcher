import 'package:flutter/widgets.dart';
import 'package:state_watcher/src/core/build_store.dart';
import 'package:state_watcher/src/widgets/watcher_element.dart';

/// A [StatefulWidget] which can be used to watch the changes of [Ref]s.
abstract class WatcherStatefulWidget extends StatefulWidget {
  /// Creates a new [WatcherStatefulWidget].
  const WatcherStatefulWidget({
    super.key,
  });

  /// The name of the widget to use in debug mode.
  @protected
  String? get debugName => null;

  @override
  StatefulElement createElement() => _WatcherStatefulElement(this);
}

class _WatcherStatefulElement extends StatefulElement with WatcherElement {
  _WatcherStatefulElement(super.widget);

  @override
  String? get debugName => (widget as WatcherStatefulWidget).debugName;
}

/// Extensions for [State]s of [WatcherStatefulWidget]s.
extension WatcherStatefulStateExtension<T extends WatcherStatefulWidget>
    on State<T> {
  /// Gets the [BuildStore] of the closest [WatcherStatefulWidget] ancestor.
  @protected
  BuildStore get store => (context as WatcherElement).buildStore;
}
