---
title: Variable
description: How to create and use a Variable.
sidebar:
  order: 2
---

A Variable reference an independent state which can be manually updated over time.

It can safely be globally declared since its state is located in a store and not in the Variable itself.

A Variable can be easily declared:
```dart
final refCounter = Variable((_) => 0);
```

Sometimes a Variable can have some dependencies which are only read when the state is created. For example a repository can have a dependency on a ApiClient:
```dart
final refRepository = Variable((read) {
  return Repository(apiClient: read(refApiClient));
});
```
:::caution
A `CircularDependencyError` can be thrown a circular dependency is detected when reading the state of a Ref.
:::

When you have Variable that has a meaning only when it is overriden, it can be useful to create it without an initial value:
```dart
final refCurrentItem = Variable<Item>.undefined();
```

:::tip[Rule]
The state of a Variable will always be created in the nearest store where it's overriden, otherwise it will be created on the root one.
:::

There are two methods on the store object to modify the state of a Variable:
```dart
// To write a new value independent of the previous one:
store.write(refVariable, 10);

// To write a new value which depends of the previous one:
store.update(refVariable, (x) => x + 1);
```

