---
title: Best Practices
description: Best practices to follow.
sidebar:
  order: 2
---

## Don't create Provided or Computed in build methods

:::danger
```dart
class MyWidget extends WatcherStatelessWidget {
  Widget build(BuildContext context, BuildStore store) {
    final userName = store.watch(Computed((watch) {
      return watch(refUser).name;
    }));
    return Text(userName);
  }
}
```
:::

Instead create them at top-level or with the static modifier

:::tip[Good]
```dart
final refUserName = Computed((watch) {
  return watch(refUser).name;
});

class MyWidget extends WatcherStatelessWidget {
  Widget build(BuildContext context, BuildStore store) {
    final userName = store.watch(refUserName);
    return Text(userName);
  }
}
```
:::


:::tip[Also Good]
```dart
class MyWidget extends WatcherStatelessWidget {
  static final _refUserName = Computed((watch) {
    return watch(refUser).name;
  });

  Widget build(BuildContext context, BuildStore store) {
    final userName = store.watch(_refUserName);
    return Text(userName);
  }
}
```
:::
