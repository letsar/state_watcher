---
title: Conventions
description: Some conventions to help being productive.
sidebar:
  order: 1
---

Here are a list of useful conventions to help you being productive.

:::tip[Prefix the Provided and Computed names with "ref"]
It will be easier to look for them and it will be easier for naming the value:

```dart
final refCounter = Provided((_) => 0);

...

// If we named our Provided counter instead of refCounter, we would had to find another name for the value counter. 
final counter = store.watch(refCounter);
```
:::

:::tip[Name the Computed.withParameter like this]
```dart "ReturnType" "ParameterMeaning"
final computedReturnTypeByParameterMeaning = Computed.withParameter...
```

For example:
```dart
final computedProductById = Computed.withParameter((watch, String productId) {
  final productIdToProduct = watch(refProductIdToProduct);
  return productIdToProduct[productId];
});

class _Product extends StatelessWidget {
  const _Product({
    required this.productId,
  });

  final String productId;

  Widget build(BuildContext context) {
    // Now we can the the desired computed like this:
    final computed = computedProductById(productId);
  }
}
```
:::