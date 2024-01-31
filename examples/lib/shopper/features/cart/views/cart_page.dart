import 'package:examples/shopper/features/cart/views/cart_page_logic.dart';
import 'package:examples/shopper/features/refs.dart';
import 'package:flutter/material.dart';
import 'package:state_watcher/state_watcher.dart';

final _refCurrentProductId = Variable<int>.undefined();
final _refCurrentProduct = Computed((watch) {
  final products = watch(refProducts);
  final productId = watch(_refCurrentProductId);
  return products.firstWhere((product) => product.id == productId);
});
final _refCartTotal = Computed((watch) {
  final products = watch(refProducts);
  final cart = watch(refCart);
  return cart.fold<double>(
    0,
    (total, productId) {
      return total +
          products.firstWhere((product) => product.id == productId).price;
    },
  );
});

class CartPage extends StatelessWidget {
  const CartPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart', style: Theme.of(context).textTheme.displayLarge),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.yellow,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: _CartList(),
              ),
            ),
            const Divider(height: 4, color: Colors.black),
            _CartTotal()
          ],
        ),
      ),
    );
  }
}

class _CartList extends WatcherStatelessWidget {
  @override
  Widget build(BuildContext context, BuildScope scope) {
    final cart = scope.watch(refCart).toList();

    return ListView.builder(
        itemCount: cart.length,
        itemBuilder: (context, index) {
          final productId = cart[index];
          return StateScope(
            overrides: {
              _refCurrentProductId.overrideWithValue(productId),
            },
            child: const _CartItemTile(),
          );
        });
  }
}

class _CartItemTile extends WatcherStatelessWidget {
  const _CartItemTile();

  static final _refProductName = Computed((watch) {
    return watch(_refCurrentProduct).name;
  });

  @override
  Widget build(BuildContext context, BuildScope scope) {
    final itemNameStyle = Theme.of(context).textTheme.titleLarge;
    final productName = scope.watch(_refProductName);

    return ListTile(
      leading: const Icon(Icons.done),
      trailing: IconButton(
        icon: const Icon(Icons.remove_circle_outline),
        onPressed: () {
          final productId = scope.read(_refCurrentProductId);
          scope.read(refCartPageLogic).removeProductFromCart(productId);
        },
      ),
      title: Text(
        productName,
        style: itemNameStyle,
      ),
    );
  }
}

class _CartTotal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hugeStyle =
        Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: 48);

    return SizedBox(
      height: 200,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StateWatcher(
              builder: (context, scope) {
                final totalPrice = scope.watch(_refCartTotal);
                return Text('\$$totalPrice', style: hugeStyle);
              },
            ),
            const SizedBox(width: 24),
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Buying not supported yet.')));
              },
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text('BUY'),
            ),
          ],
        ),
      ),
    );
  }
}
