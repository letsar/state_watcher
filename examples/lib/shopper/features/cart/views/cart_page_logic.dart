import 'package:examples/shopper/features/refs.dart';
import 'package:state_watcher/state_watcher.dart';

final refCartPageLogic = Provided((_) => CartPageLogic());

class CartPageLogic with StateLogic {
  CartPageLogic();

  void removeProductFromCart(int productId) {
    update(refCart, (cart) => {...cart}..remove(productId));
  }
}
