import 'package:examples/pub/features/details/data/models/package.dart';
import 'package:examples/pub/features/details/data/sources/details_api.dart';
import 'package:examples/pub/features/pagination/data/models/paginated_data.dart';
import 'package:examples/pub/features/search/data/sources/search_api.dart';
import 'package:state_watcher/state_watcher.dart';

final refSearchRepository = Provided((read) {
  final searchApi = read(refSearchApi);
  final detailsApi = read(refDetailsApi);
  return SearchRepository(
    searchApi: searchApi,
    detailsApi: detailsApi,
  );
});

final class SearchRepository with StateLogic {
  SearchRepository({
    required SearchApi searchApi,
    required DetailsApi detailsApi,
  })  : _searchApi = searchApi,
        _detailsApi = detailsApi;

  final SearchApi _searchApi;
  final DetailsApi _detailsApi;

  Future<PaginatedData<Package>> searchPackages({
    required String query,
  }) async {
    if (query.isEmpty) {
      final response = await _searchApi.fetchPackages();
      return PaginatedData(
        data: response.packages,
        cursor: response.nextUrl,
      );
    }

    // We need to use the `search` endpoint first.
    final response = await _searchApi.searchPackages(query: query);
    // Then we need to get all the packages details.
    final details = await Future.wait(
      response.packages.map((x) => _detailsApi.fetchPackage(name: x.package)),
    );

    return PaginatedData(
      data: details,
      cursor: response.next,
    );
  }

  Future<PaginatedData<Package>> searchPackagesFromUrl({
    required String query,
    required String url,
  }) async {
    if (query.isEmpty) {
      final response = await _searchApi.fetchPackagesFromUrl(url: url);
      return PaginatedData(
        data: response.packages,
        cursor: response.nextUrl,
      );
    }

    // We need to use the `search` endpoint first.
    final response = await _searchApi.searchPackagesFromUrl(url: url);

    // Then we need to get all the packages details.
    final details = await Future.wait(
      response.packages.map((x) => _detailsApi.fetchPackage(name: x.package)),
    );

    return PaginatedData(
      data: details,
      cursor: response.next,
    );
  }
}
