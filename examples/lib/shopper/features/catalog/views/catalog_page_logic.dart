import 'package:examples/common/loadable.dart';
import 'package:examples/shopper/features/catalog/data/repositories/catalog_repository.dart';
import 'package:examples/shopper/features/refs.dart';
import 'package:state_watcher/state_watcher.dart';

final refCatalogPageLogic = Variable((_) => CatalogPageLogic());

class CatalogPageLogic with StateLogic implements Loadable {
  CatalogPageLogic();

  CatalogRepository get catalogRepository => read(refCatalogRepository);

  @override
  Future<void> load() async {
    final products = await catalogRepository.fetchProducts();
    write(refProducts, products);
  }

  void addProductToCart(int productId) {
    update(refCart, (cart) => {...cart, productId});
  }
}
