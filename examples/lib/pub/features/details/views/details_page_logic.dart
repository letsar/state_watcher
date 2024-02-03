import 'package:examples/common/loadable.dart';
import 'package:examples/pub/features/details/data/models/package_metrics_score.dart';
import 'package:examples/pub/features/details/data/repositories/details_repository.dart';
import 'package:state_watcher/state_watcher.dart';

final refDetailsPageLogic = Provided<DetailsPageLogic>.undefined();
final refPackageNameToMetricsScore =
    Provided((_) => <String, PackageMetricsScore>{});

class DetailsPageLogic with StateLogic implements Loadable {
  DetailsPageLogic({
    required this.packageName,
    required DetailsRepository detailsRepository,
  }) : _detailsRepository = detailsRepository;

  final DetailsRepository _detailsRepository;
  final String packageName;

  @override
  Future<void> load() async {
    final cache = read(refPackageNameToMetricsScore);
    final metrics = cache[packageName];
    if (metrics == null) {
      final score = await _detailsRepository.fetchPackageMetricsScore(
        name: packageName,
      );
      final newCache = Map<String, PackageMetricsScore>.from(cache);
      newCache[packageName] = score;
      write(refPackageNameToMetricsScore, newCache);
    }
  }
}
