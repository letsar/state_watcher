---
title: Provided
description: How to create and use a Provided.
sidebar:
  order: 2
---

A `Provided` references an independent state which can be manually updated over time.

A `Provided` can be easily declared:
```dart
// Here we declare a Provided with an initial state of 0.
final refCounter = Provided((_) => 0);
```

Sometimes a `Provided` can have some dependencies which are only read when the state is created. For example a repository can have a dependency on an api client:
```dart
/// Use read to inject dependencies when creating your instances.
final refRepository = Provided((read) {
  return Repository(apiClient: read(refApiClient));
});
```
:::caution
A `CircularDependencyError` can be thrown when a circular dependency is detected when reading the state of a Ref.
:::

When you have a `Provided` that has a meaning only when it is overriden, it can be useful to create it without an initial value:
```dart
final refCurrentItem = Provided<Item>.undefined();
```

:::tip[Rule]
The state of a `Provided` will always be created in the nearest store where it's overriden, otherwise it will be created on the root one.
:::

There are two methods on the store object to modify the state of a `Provided`:
```dart
// To write a new value independent of the previous one:
store.write(refProvided, 10);

// To write a new value which depends of the previous one:
store.update(refProvided, (x) => x + 1);
```

:::tip
Since the state referenced by a `Provided` is located in a store, a `Provided` can, and should be declared at top-level or with the `static` modifier.
:::

:::danger
In particular do not create a `Provided` inside a build method, it could lead to unexpected behavior and memory leaks.
:::

:::note
By default a `Provided`'s state **is not** removed automatically from the store when it is no longer used. It's up to you to delete it when you want.

This decision has been made because the state of a `Provided` is important and cannot be retrieved if it's deleted.
:::

