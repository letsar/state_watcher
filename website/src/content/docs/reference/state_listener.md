---
title: StateListener
description: What is StateListener.
sidebar:
  order: 6
---

Sometimes we don't want to rebuild the UI but we want to execute some code when a state changes.
In this case we can use the `StateListener` widget:

```dart
return StateListener(
  ref: refCounter,
  onStateChanged: (context, oldValue, newValue) {
    // Do whatever you want with when the value changes.
  },
);
```