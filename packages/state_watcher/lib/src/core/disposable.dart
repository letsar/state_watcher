import 'package:meta/meta.dart';

/// Interface for components that need to release resources before they are
/// removed from the scope where they are stored.
abstract class Disposable {
  /// Releases resources used by the object.
  @mustCallSuper
  void dispose();
}
