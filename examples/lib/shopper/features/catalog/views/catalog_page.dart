// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:examples/common/widgets/loader.dart';
import 'package:examples/shopper/features/catalog/views/catalog_page_logic.dart';
import 'package:examples/shopper/features/products/data/models/product.dart';
import 'package:examples/shopper/features/refs.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:state_watcher/state_watcher.dart';

final _refCurrentProduct = Variable<Product>.undefined();

class CatalogPage extends WatcherStatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context, BuildStore store) {
    final products = store.watch(refProducts);

    return Loader(
      refs: [refCatalogPageLogic],
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            _AppBar(),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                childCount: products.length,
                (context, index) {
                  final product = products[index];

                  return StateStore(
                    overrides: {
                      _refCurrentProduct.overrideWithValue(product),
                    },
                    child: const _Product(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text('Catalog', style: Theme.of(context).textTheme.displayLarge),
      floating: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_cart),
          onPressed: () => context.go('/catalog/cart'),
        ),
      ],
    );
  }
}

class _Product extends WatcherStatelessWidget {
  const _Product();

  @override
  Widget build(BuildContext context, BuildStore store) {
    final product = store.watch(_refCurrentProduct);
    var textTheme = Theme.of(context).textTheme.titleLarge;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: LimitedBox(
        maxHeight: 48,
        child: Row(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: product.color,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Text(product.name, style: textTheme),
            ),
            const SizedBox(width: 24),
            const _AddButton(),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends WatcherStatelessWidget {
  const _AddButton();

  static final _refIsInCart = Computed((watch) {
    final cart = watch(refCart);
    final productId = watch(_refCurrentProduct).id;
    return cart.contains(productId);
  });

  @override
  Widget build(BuildContext context, BuildStore store) {
    final isInCart = store.watch(_refIsInCart);

    return TextButton(
      onPressed: isInCart
          ? null
          : () {
              final productId = store.read(_refCurrentProduct).id;
              store.read(refCatalogPageLogic).addProductToCart(productId);
            },
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
          if (states.contains(MaterialState.pressed)) {
            return Theme.of(context).primaryColor;
          }
          return null; // Defer to the widget's default.
        }),
      ),
      child: isInCart
          ? const Icon(Icons.check, semanticLabel: 'ADDED')
          : const Text('ADD'),
    );
  }
}
