---
title: StateObserver
description: What is StateObserver.
sidebar:
  order: 7
---

It can be useful to be able to observe all the state changes in a store (for logging purpose for example).

In that case you'll need to create a `StateObserver` and pass it to the `StateStore` you want to observe:

```dart
class MyObserver extends StateObserver {
  const MyObserver();

  @override
  void didStateCreated<T>(Store store, Ref<T> ref, T value) {
    if (kDebugMode) {
      print('[MyObserver] didStateCreated: $ref with value: $value}');
    }
  }

  @override
  void didStateUpdated<T>(Store store, Ref<T> ref, T oldValue, T newValue) {
    if (kDebugMode) {
      print('[MyObserver] didStateUpdated: $ref: from $oldValue to $newValue');
    }
  }

  @override
  void didStateDeleted<T>(Store store, Ref<T> ref) {
    if (kDebugMode) {
      print('[MyObserver] didStateUpdated: $ref');
    }
  }
}

...

return StateStore(
  observers: const [MyObserver()],
  child: ...
);
```

