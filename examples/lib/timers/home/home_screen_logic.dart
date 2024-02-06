import 'dart:math';

import 'package:examples/timers/models/expirable.dart';
import 'package:state_watcher/state_watcher.dart';

final refHomeScreenLogic = Provided((_) => HomeScreenLogic());
final refExpirables = Provided((_) => <Expirable>[]);

class HomeScreenLogic with StateLogic {
  final _random = Random();
  int _currentId = 0;

  void addExpirable() {
    final expirationDate = DateTime.now().add(
      Duration(seconds: _random.nextInt(45) + 30),
    );
    final id = _currentId++;
    final expirable = Expirable(id, expirationDate);
    update(refExpirables, (x) => [...x, expirable]);
  }

  void removeExpirable(int id) {
    update(refExpirables, (x) => x.where((e) => e.id != id).toList());
  }
}
