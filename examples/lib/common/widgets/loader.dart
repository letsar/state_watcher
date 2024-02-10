import 'package:examples/common/loadable.dart';
import 'package:flutter/widgets.dart';
import 'package:state_watcher/state_watcher.dart';

class Loader extends WatcherStatefulWidget {
  const Loader({
    super.key,
    required this.refs,
    required this.child,
  });

  final List<Ref<Loadable>> refs;
  final Widget child;

  @override
  State<Loader> createState() => _LoaderState();
}

class _LoaderState extends State<Loader> {
  Future<void>? loader;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loader ??= load();
  }

  Future<void> load() async {
    await Future.wait(widget.refs.map((x) => store.read(x).load()));
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
