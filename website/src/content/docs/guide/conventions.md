---
title: Conventions
description: Some conventions to help being productive.
sidebar:
  order: 1
---

Here are a list of useful conventions to help you being productive.

:::tip
Prefix the Variable and Compute names with **ref**.
It will be easier to look for them and it will be easier for naming the value:

```dart
final refCounter = Variable((_) => 0);

...

// If we named our Variable counter instead of refCounter, we would had to find another name for the value counter. 
final counter = store.watch(refCounter);
```
:::