import 'package:uuid/uuid.dart';

const Uuid _uuid = Uuid();

class Todo {
  Todo({
    String? id,
    required this.description,
    this.completed = false,
  }) : id = id ?? _uuid.v4();

  final String id;
  final String description;
  final bool completed;

  @override
  bool operator ==(Object other) {
    return other is Todo &&
        other.id == id &&
        other.description == description &&
        other.completed == completed;
  }

  @override
  int get hashCode => Object.hashAll([id, description, completed]);

  @override
  String toString() {
    return 'Todo(description: $description, completed: $completed)';
  }
}

enum TodoListFilter {
  all,
  active,
  completed,
}
