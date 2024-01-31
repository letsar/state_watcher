import 'package:examples/common/widgets/loader.dart';
import 'package:examples/pub/features/core/views/pub_app_bar.dart';
import 'package:examples/pub/features/details/data/models/package.dart';
import 'package:examples/pub/features/details/data/repositories/details_repository.dart';
import 'package:examples/pub/features/details/views/details_page_logic.dart';
import 'package:examples/pub/features/search/views/search_page_logic.dart';
import 'package:flutter/material.dart';
import 'package:state_watcher/state_watcher.dart';

final _refCurrentPackage = Variable<Package>.undefined();
final _refCurrentPackageMetricsScore = Computed((watch) {
  final packageName = watch(_refCurrentPackage).name;
  return watch(refPackageNameToMetricsScore)[packageName];
});

class DetailsPage extends WatcherStatelessWidget {
  const DetailsPage({
    super.key,
    required this.packageName,
  });

  final String packageName;

  static final _refPackage = Computed.withParameter(
    (watch, String packageName) {
      return watch(refPackageNameToPackage)[packageName]!;
    },
  );

  @override
  Widget build(BuildContext context, BuildScope scope) {
    final package = scope.watch(_refPackage(packageName));

    return StateScope(
      overrides: {
        refDetailsPageLogic.overrideWith((read) {
          return DetailsPageLogic(
            packageName: packageName,
            detailsRepository: read(refDetailsRepository),
          );
        }),
        _refCurrentPackage.overrideWithValue(package),
      },
      child: Scaffold(
        appBar: const PubAppBar(),
        body: Loader(refs: [refDetailsPageLogic], child: const _Body()),
      ),
    );
  }
}

class _Body extends WatcherStatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context, BuildScope scope) {
    final package = scope.watch(_refCurrentPackage);
    final packageName = package.name;
    final packageVersion = package.latest.version;
    final packageDescription = package.latest.pubspec.description;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      children: [
        Text(
          '$packageName $packageVersion',
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 10),
        Text(packageDescription ?? ''),
        const SizedBox(height: 40),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Likes(),
            _Points(),
            _Popularity(),
          ],
        ),
      ],
    );
  }
}

class _Likes extends WatcherStatelessWidget {
  const _Likes();

  static final _refLikeCount = Computed((watch) {
    return watch(_refCurrentPackageMetricsScore)?.likeCount;
  });

  @override
  Widget build(BuildContext context, BuildScope scope) {
    final likeCount = scope.watch(_refLikeCount);

    final widget = likeCount == null
        ? const CircularProgressIndicator()
        : Text(
            '$likeCount',
            style: const TextStyle(
              color: Color(0xff1967d2),
              fontSize: 40,
            ),
          );

    return Column(
      children: [
        widget,
        const Text('LIKES', style: TextStyle(fontSize: 13)),
      ],
    );
  }
}

class _Points extends WatcherStatelessWidget {
  const _Points();

  static final _refPoints = Computed((watch) {
    final score = watch(_refCurrentPackageMetricsScore);
    if (score == null) {
      return null;
    }
    return (grantedPoints: score.grantedPoints, maxPoints: score.maxPoints);
  });

  @override
  Widget build(BuildContext context, BuildScope scope) {
    final points = scope.watch(_refPoints);

    final widget = points == null
        ? const CircularProgressIndicator()
        : Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${points.grantedPoints}',
                style: const TextStyle(
                  color: Color(0xff1967d2),
                  fontSize: 40,
                ),
              ),
              Text(
                '/${points.maxPoints}',
                style: const TextStyle(
                  color: Color(0xff1967d2),
                  fontSize: 20,
                ),
              ),
            ],
          );

    return Column(
      children: [
        widget,
        const Text(
          'PUB POINTS',
          style: TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}

class _Popularity extends WatcherStatelessWidget {
  const _Popularity();

  static final _refPopularity = Computed((watch) {
    final score = watch(_refCurrentPackageMetricsScore)?.popularityScore;
    if (score == null) {
      return null;
    }
    return score * 100;
  });

  @override
  Widget build(BuildContext context, BuildScope scope) {
    final popularity = scope.watch(_refPopularity);

    final widget = popularity == null
        ? const CircularProgressIndicator()
        : Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${popularity.round()}',
                style: const TextStyle(
                  color: Color(0xff1967d2),
                  fontSize: 40,
                ),
              ),
              const Text(
                '%',
                style: TextStyle(
                  color: Color(0xff1967d2),
                  fontSize: 20,
                ),
              ),
            ],
          );

    return Column(
      children: [
        widget,
        const Text(
          'POPULARITY',
          style: TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}
