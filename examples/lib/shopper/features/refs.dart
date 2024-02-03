import 'package:examples/shopper/features/products/data/models/product.dart';
import 'package:state_watcher/state_watcher.dart';

final refCart = Provided((_) => <int>{});
final refProducts = Provided((_) => <Product>[]);
