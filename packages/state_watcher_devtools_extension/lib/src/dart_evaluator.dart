import 'package:devtools_app_shared/service.dart' as devtools_shared;
import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:state_watcher/state_watcher.dart';
import 'package:vm_service/vm_service.dart';

const _libraryPath = 'package:state_watcher/src/core/refs.dart';

/// Not used for now, but could be useful in the future if we want to get the
/// actual value of a node instead of a String.
class DartEvaluator extends Disposable {
  late final devtools_shared.Disposable _disposable;
  late final devtools_shared.EvalOnDartLibrary _eval;

  void init() {
    _disposable = devtools_shared.Disposable();
    _eval = devtools_shared.EvalOnDartLibrary(
      _libraryPath,
      serviceManager.service!,
      serviceManager: serviceManager,
    );
  }

  Future<InstanceRef> fetchValue(String nodeId) async {
    final instance = await _eval.evalInstance(
      'StateInspector.instance._nodes["$nodeId"]',
      isAlive: _disposable,
    );

    return _eval.safeGetInstance(
      instance.fields!.firstWhere((e) => e.decl?.name == '_value').value
          as InstanceRef,
      _disposable,
    );
  }

  @override
  void dispose() {
    _disposable.dispose();
    _eval.dispose();
  }
}
