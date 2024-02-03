---
title: Store
description: What is a Store and how to create one.
sidebar:
  order: 1
---

In **state_watcher**, a store contains the actual states referenced by [Variables][variable] or [Computeds][computed] (also called, as a generic term, Refs).

:::note
In the rest of the documentation we will often shorten *The state referenced by this Variable* by *The state of the Variable*.
:::

Let's take the following example: We have two Variables **a** and **b**, and 5 Computed named **c** through **g**. The Computeds **c**, **d**, and **e** depend on the state of the Variable **a**. The Computeds **e**, **f**, and **g** depend on the states of the Variable **b**.
Let's say all their states are stored in the store number 0.

In the illustration below, representing these relationships, the states are called with the name of their Ref followed by the id of the store (0 here). The states of the Variables are in purple and the states of the Computeds are in yellow.

![Store Example 1](../../../assets/store_example_1.png).

In **state_watcher** each store can have a parent store. This is useful if we want to override the value of a Variable by something else.
For example, let's say we have a store 1 depending on the store 0 and in this store we override the Variable **a**. In this case we can representing the relations by the image below:

![Store Example 2](../../../assets/store_example_2.png).

As you can see, now we have another state for the Variable **a** in the store number 1, and all the Computeds have also another state in the store 1. This is because otherwise the location of the state of a Computed could change over time and it would be too complicated handle it.
But since Refs are lazily created, **f1** and **g1** would not be created before we want to evaluate them.

:::tip[Rules]
To know where the state of a Ref will be stored there are two simple rules:
- The state of a Variable will always be created in the nearest store where it's overriden, otherwise it will be created on the root one.
- The state of a Computed is always created in the nearest store.
:::

A concrete use case for overriding a Variable is when you have a list of elements, and you want to have dedicated store for each element where the Variable representing the current element is overriden in a dedicated store.


## Flutter Widget

To create a store in Flutter, we just have to insert a `StateStore` widget in our tree. Typically we'll add one at the root of our app in order to store in it our common states between our screens.

```dart
StateStore(
  child: MyWidget(),
);
```

If you want to override some Variables in a `StateStore`, you have a `overrides` set for that:
```dart
StateStore(
  overrides: {
    a.overrideWithValue(10),
  },
  child: MyWidget(),
);
```

<!-- Links -->
[variable]: /state_watcher/reference/variable
[computed]: /state_watcher/reference/computed
