import 'package:examples/shopper/features/products/data/models/product.dart';
import 'package:state_watcher/state_watcher.dart';

final refCart = Variable((_) => <int>{});
final refProducts = Variable((_) => <Product>[]);
