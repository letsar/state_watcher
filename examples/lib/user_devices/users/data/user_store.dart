import 'package:examples/user_devices/core/data/store.dart';
import 'package:examples/user_devices/users/data/models/user.dart';
import 'package:examples/user_devices/users/data/sources/user_api.dart';
import 'package:state_watcher/state_watcher.dart';

final refUserMap = Variable((_) => const <int, User>{});
final refUserStore = Variable((_) => UserStore());

class UserStore extends Store<User> {
  UserStore() : super(refUserMap);

  UserApi get _apiClient => read(refUserApi);

  @override
  Future<Iterable<User>> fetch() {
    return _apiClient.fetchUsers();
  }
}
