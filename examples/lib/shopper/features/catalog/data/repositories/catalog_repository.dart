import 'package:examples/shopper/features/products/data/models/product.dart';
import 'package:state_watcher/state_watcher.dart';

final refCatalogRepository = Variable((_) => const CatalogRepository());

class CatalogRepository {
  const CatalogRepository();

  static const _productNames = [
    'Code Smell',
    'Control Flow',
    'Interpreter',
    'Recursion',
    'Sprint',
    'Heisenbug',
    'Spaghetti',
    'Hydra Code',
    'Off-By-One',
    'Scope',
    'Callback',
    'Closure',
    'Automata',
    'Bit Shift',
    'Currying',
  ];

  Future<List<Product>> fetchProducts() async {
    return _productNames.indexed.map((e) => Product(e.$1, e.$2)).toList();
  }
}
