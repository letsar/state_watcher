---
title: Overview
description: An overview of state_watcher.
sidebar:
  order: 2
---

In my mind, the global state of an application is a set of independents sources of truth and derived states computed from them and other states.
For example a list of transactions can be a source of truth and the sum of these transactions is a derived state. When the list changes, we want the sum to be updated automatically.

In **state_watcher**, the sources of truth are referenced through [Variables][variable] and the derived states through [Computeds][computed].

I used the word *referenced* because the actual state is not stored in [Variables][variable] and [Computeds][computed], they are simply references to get their associated value.

The states are located in a [Store][store] and it is through this object that you can interact with the actual values.

The last fundamental pieces of **state_watcher** are the [watchers][watchers]. They are the Flutter widgets used to watch the changes in the states and rebuild accordingly.

These are the core concepts of **state_watcher**, and you can build a Flutter application using only this. But for a better separation between the view and the business logic there is another important component: the [StateLogic][state_logic].

<!-- Links -->
[variable]: /state_watcher/reference/variable
[computed]: /state_watcher/reference/computed
[store]: /state_watcher/reference/store
[watchers]: /state_watcher/reference/watchers
[state_logic]: /state_watcher/reference/state_logic