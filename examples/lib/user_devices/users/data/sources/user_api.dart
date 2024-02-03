import 'package:examples/user_devices/core/data/sources/fake_api.dart';
import 'package:examples/user_devices/users/data/models/user.dart';
import 'package:state_watcher/state_watcher.dart';

final refUserApi = Provided((_) => UserApi());

const List<User> _users = <User>[
  User(id: 1, firstName: 'Alice', lastName: 'Alpha', deviceIds: <int>[2]),
  User(id: 2, firstName: 'Bob', lastName: 'Bravo', deviceIds: <int>[]),
  User(id: 3, firstName: 'Carole', lastName: 'Charlie', deviceIds: <int>[]),
  User(id: 4, firstName: 'Damien', lastName: 'Delta', deviceIds: <int>[3, 4]),
  User(id: 5, firstName: 'Estelle', lastName: 'Echo', deviceIds: <int>[]),
  User(id: 6, firstName: 'Franck', lastName: 'Ford', deviceIds: <int>[]),
];

class UserApi extends FakeApi {
  Future<List<User>> fetchUsers() => delay(_users);
}
