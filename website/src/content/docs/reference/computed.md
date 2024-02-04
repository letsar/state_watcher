---
title: Computed
description: How to create and use a Computed.
sidebar:
  order: 3
---

In an application, we don't always need a whole state, sometimes we just need a piece of that information, or we need to combine multiple states into one. That's where `Computed` fits in!

```dart
// Here we are only interested in a part of the user: its name.
final refUserName = Computed((watch){
  // We need to get the user state.
  final user = watch(refUser);

  // We only want the user's name.
  return user.name;
});
```

Every time the user state changes, this `Computed` callback is re-executed and if the resulting value is different, it will then notify the components watching it.

```dart
// Here we want to get the total price of products in a cart.
final refTotalPrice = Computed((watch){
  // We get the map where the key is the product's id 
  // and the value is the product.
  final productById = watch(refProducts);

  // We get another state: the cart. 
  final cart = watch(refCart);

  // We compute the sum of the price of all products in our cart.
  final totalPrice = cart.productIds
                         .map((id) => productById[id]?.price)
                         .whereNotNull()
                         .sum();
  return totalPrice;
});
```

In the last example, everytime the cart or the product map changes, the `Computed` callback is re-executed automatically, and it's only when the total price changes between two executions, that the components that are interested in this value, are notified.

:::tip
Since the state referenced by a `Computed` is located in a store, a `Computed` can, and should be declared at top-level or with the `static` modifier.
:::

:::danger
In particular do not create a `Computed` inside a build method, it could lead to unexpected behavior and memory leaks.
:::

## Computed with Parameter

Let's say you have a widget which has a `productId` parameter and you want to get the product with this id.

```dart
class _Product extends StatelessWidget {
  const _Product({
    required this.productId,
  });

  final String productId;

  Widget build(BuildContext context) {
    ...
  }
}
```

Since we must not create a `Computed` inside a build method, how can we get a `Computed` which depends on `productId`?

One way to do it, is to have a specific Provided for the current product id and to override it in a `StateStore`:

```dart
final refCurrentProductId = Provided<String>.undefined();
final refCurrentProduct = Computed((watch){
  final currentProductId = watch(refCurrentProductId);
  final productIdToProduct = watch(refProductIdToProduct);
  return productIdToProduct[currentProductId];
});

class _Product extends StatelessWidget {
  const _Product({
    required this.productId,
  });

  final String productId;

  Widget build(BuildContext context) {
    return StateStore(
      overrides: {
        refCurrentProductId.withValue(productId),
      },
      child: Builder(
        builder: (context) {
          // Now in this subtree we if we watch refCurrentProduct, 
          // we will get the currentProduct. 
        },
      ),
    );
    ...
  }
}
```

As you can see, this is pretty cumbersome.
Another way would be to safely generate a `Computed` on the fly, with a parameter. And this is possible:

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

This is far more easier and it's safe because the generated `Computed` can be tracked and disposed properly when it's not longer in used.

:::note
By default a `Computed`'s state **is** removed automatically from the store when it is no longer used. You can opt-out for this behavior by setting `autoDispose` parameter to `false` when creating a `Computed`.

In this case it is your responsability to remove it when is no longer used to avoid having the memory growing up.
:::