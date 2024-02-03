import 'package:examples/pub/features/details/data/models/package_metrics_score.dart';
import 'package:examples/pub/features/details/data/sources/details_api.dart';
import 'package:state_watcher/state_watcher.dart';

final refDetailsRepository = Provided((read) {
  final detailsApi = read(refDetailsApi);
  return DetailsRepository(detailsApi: detailsApi);
});

class DetailsRepository {
  const DetailsRepository({
    required DetailsApi detailsApi,
  }) : _detailsApi = detailsApi;

  final DetailsApi _detailsApi;

  Future<PackageMetricsScore> fetchPackageMetricsScore({
    required String name,
  }) async {
    return _detailsApi.fetchPackageMetricsScore(name: name);
  }
}
