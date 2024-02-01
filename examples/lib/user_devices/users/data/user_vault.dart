import 'package:examples/user_devices/core/data/vault.dart';
import 'package:examples/user_devices/users/data/models/user.dart';
import 'package:examples/user_devices/users/data/sources/user_api.dart';
import 'package:state_watcher/state_watcher.dart';

final refUserMap = Variable((_) => const <int, User>{});
final refUserVault = Variable((_) => UserVault());

class UserVault extends Vault<User> {
  UserVault() : super(refUserMap);

  UserApi get _apiClient => read(refUserApi);

  @override
  Future<Iterable<User>> fetch() {
    return _apiClient.fetchUsers();
  }
}
