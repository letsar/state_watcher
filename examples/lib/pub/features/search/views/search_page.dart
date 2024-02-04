import 'package:examples/pub/features/core/views/pub_app_bar.dart';
import 'package:examples/pub/features/details/data/models/package.dart';
import 'package:examples/pub/features/details/views/details_page.dart';
import 'package:examples/pub/features/search/views/search_page_logic.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:state_watcher/state_watcher.dart';

final _refCurrentPackage = Provided<Package>.undefined();

class SearchPage extends StatelessWidget {
  const SearchPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: PubAppBar(
        bottom: _SearchBar(),
      ),
      body: _Body(),
    );
  }
}

class _SearchBar extends WatcherStatelessWidget implements PreferredSizeWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context, BuildStore store) {
    return SizedBox(
      height: 64,
      child: Center(
        child: Container(
          margin: const EdgeInsets.fromLTRB(32, 0, 32, 16),
          decoration: const ShapeDecoration(
            shape: StadiumBorder(),
            color: Color(0xff35404d),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  // contentPadding: EdgeInsets.zero,
                  hintText: 'Search packages',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                ),
                onEditingComplete: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                onSubmitted: (value) {
                  store.read(refSearchPageLogic).searchPackages(value);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}

class _Body extends WatcherStatelessWidget {
  const _Body();

  static final _data = Computed((watch) {
    final searchResults = watch(refPaginatedSearchResults).results;
    final data = searchResults.data;
    return (
      packages: data ?? const [],
      hasMore: searchResults.cursor != null || data == null,
    );
  });

  @override
  Widget build(BuildContext context, BuildStore store) {
    final data = store.watch(_data);

    return ListView.builder(
      itemCount: data.hasMore ? null : data.packages.length,
      itemBuilder: (context, index) {
        return _Package(index: index);
      },
    );
  }
}

class _Package extends WatcherStatefulWidget {
  const _Package({
    required this.index,
  });

  final int index;

  @override
  State<_Package> createState() => _PackageState();
}

class _PackageState extends State<_Package> {
  @override
  void initState() {
    super.initState();
    store.read(refSearchPageLogic).loadPackage(widget.index);
  }

  static final _computedPackageByIndex =
      Computed.withParameter((watch, int index) {
    final results = watch(refPaginatedSearchResults);
    final packages = results.results.data;
    if (packages == null || packages.length <= index) {
      return null;
    }
    return packages[index];
  }, debugName: 'package');

  @override
  Widget build(BuildContext context) {
    final package = store.watch(_computedPackageByIndex(widget.index));

    if (package == null) {
      return const _PackageItemShimmer();
    }

    return StateStore(
      overrides: {
        _refCurrentPackage.overrideWithValue(package),
      },
      child: const _PackageItem(),
    );
  }
}

class _PackageItem extends WatcherStatelessWidget {
  const _PackageItem();

  static final _refData = Computed((watch) {
    final package = watch(_refCurrentPackage);
    return (
      name: package.name,
      version: package.latest.version,
      description: package.latest.pubspec.description,
    );
  });

  @override
  Widget build(BuildContext context, BuildStore store) {
    final data = store.watch(_refData);

    final name = data.name;
    final version = data.version;
    final description = data.description;

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) {
              return DetailsPage(packageName: name);
            },
          ),
        );
      },
      title: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xff0175c2),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Text(version),
        ],
      ),
      subtitle: description != null ? Text(description) : null,
    );
  }
}

class _PackageItemShimmer extends StatelessWidget {
  const _PackageItemShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.white,
      child: ListTile(
        title: Builder(
          builder: (context) {
            return Row(
              children: [
                Container(
                  height: DefaultTextStyle.of(context).style.fontSize! * .8,
                  width: 100,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.all(
                      Radius.circular(50),
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  height: DefaultTextStyle.of(context).style.fontSize! * .8,
                  width: 40,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.all(
                      Radius.circular(50),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        subtitle: Builder(
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: [
                  Container(
                    height: DefaultTextStyle.of(context).style.fontSize! * .8,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(
                        Radius.circular(50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    height: DefaultTextStyle.of(context).style.fontSize! * .8,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(
                        Radius.circular(50),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
