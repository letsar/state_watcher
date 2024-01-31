import 'package:meta/meta.dart';

const Duration _fakeDuration = Duration(milliseconds: 300);

abstract class FakeApi {
  @protected
  Future<T> delay<T>(T value) {
    return Future<void>.delayed(_fakeDuration).then((x) => value);
  }
}
