import 'package:examples/pub/features/network/api_client.dart';
import 'package:examples/pub/features/search/data/models/search_response.dart';
import 'package:state_watcher/state_watcher.dart';

final refSearchApi = Variable((read) {
  final client = read(refApiClient);
  return SearchApi(client: client);
});

class SearchApi {
  const SearchApi({
    required ApiClient client,
  }) : _client = client;

  final ApiClient _client;

  Future<SearchResponse> searchPackages({
    required String query,
  }) async {
    final json = await _client.send(
      method: HttpMethod.get,
      path: 'search',
      queryParameters: {
        'q': query,
      },
    );

    return SearchResponse.fromJson(json);
  }

  Future<SearchResponse> searchPackagesFromUrl({
    required String url,
  }) async {
    final json = await _client.sendFromUri(
      method: HttpMethod.get,
      uri: Uri.parse(url),
    );

    return SearchResponse.fromJson(json);
  }

  Future<PackagesResponse> fetchPackages() async {
    final json = await _client.send(
      method: HttpMethod.get,
      path: 'packages',
    );

    return PackagesResponse.fromJson(json);
  }

  Future<PackagesResponse> fetchPackagesFromUrl({
    required String url,
  }) async {
    final json = await _client.sendFromUri(
      method: HttpMethod.get,
      uri: Uri.parse(url),
    );

    return PackagesResponse.fromJson(json);
  }
}
