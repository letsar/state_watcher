import 'package:examples/pub/features/details/data/models/package.dart';
import 'package:examples/pub/features/details/data/models/package_metrics_score.dart';
import 'package:examples/pub/features/network/api_client.dart';
import 'package:state_watcher/state_watcher.dart';

final refDetailsApi = Provided((read) {
  final client = read(refApiClient);
  return DetailsApi(client: client);
});

class DetailsApi {
  const DetailsApi({
    required ApiClient client,
  }) : _client = client;

  final ApiClient _client;

  Future<Package> fetchPackage({
    required String name,
  }) async {
    final response = await _client.send(
      method: HttpMethod.get,
      path: 'packages/$name',
    );

    return Package.fromJson(response);
  }

  Future<PackageMetricsScore> fetchPackageMetricsScore({
    required String name,
  }) async {
    final response = await _client.send(
      method: HttpMethod.get,
      path: 'packages/$name/metrics',
    );

    final metrics = PackageMetricsResponse.fromJson(response);
    return metrics.score;
  }
}
