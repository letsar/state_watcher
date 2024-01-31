import 'dart:async';

import 'package:examples/pub/features/details/data/models/package.dart';
import 'package:examples/pub/features/pagination/data/models/paginated_data.dart';
import 'package:examples/pub/features/search/data/repositories/search_repository.dart';
import 'package:state_watcher/state_watcher.dart';

final refSearchPageLogic = Variable((read) {
  return SearchPageLogic(
    searchRepository: read(refSearchRepository),
  );
});

final refPaginatedSearchResults = Variable((_) => const SearchResults.empty());
final refPackageNameToPackage = Variable((_) => const <String, Package>{});

class SearchPageLogic with StateLogic {
  SearchPageLogic({
    required SearchRepository searchRepository,
  }) : _searchRepository = searchRepository;

  final SearchRepository _searchRepository;
  Completer<void>? _loadMoreCompleter;

  Future<void> searchPackages(String query) async {
    _writeResults(
      SearchResults(query: query, results: const PaginatedData.empty()),
    );
    final data = await _searchRepository.searchPackages(query: query);
    final results = SearchResults(query: query, results: data);
    _writeResults(results);
  }

  Future<void> loadPackage(int index) async {
    if (_loadMoreCompleter case final loadMoreCompleter?) {
      await loadMoreCompleter.future;
    }
    final loadMoreCompleter = Completer<void>();
    _loadMoreCompleter = loadMoreCompleter;

    try {
      var results = read(refPaginatedSearchResults);
      if (results.query == '' && results.results.data == null) {
        await searchPackages('');
        results = read(refPaginatedSearchResults);
      }
      while ((results.results.data?.length ?? 0) <= index &&
          results.results.cursor != null) {
        final data = await _searchRepository.searchPackagesFromUrl(
          query: results.query,
          url: results.results.cursor!,
        );
        results = SearchResults(
          query: results.query,
          results: results.results.merge(data),
        );
        _writeResults(results);
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    } finally {
      _loadMoreCompleter = null;
      loadMoreCompleter.complete();
    }
  }

  void _writeResults(SearchResults results) {
    if (results.results.data case final data?) {
      final packages = Map<String, Package>.from(read(refPackageNameToPackage));
      for (final package in data) {
        packages.putIfAbsent(package.name, () => package);
      }
      write(refPackageNameToPackage, packages);
    }
    write(refPaginatedSearchResults, results);
  }
}

class SearchResults {
  const SearchResults.empty()
      : query = '',
        results = const PaginatedData.empty();

  const SearchResults({
    required this.query,
    required this.results,
  });

  final String query;
  final PaginatedData<Package> results;
}
