import 'package:state_watcher/state_watcher.dart';

import '../entities/todo.dart';

final refTodoList = Provided(
  debugName: 'todoList',
  (_) => <Todo>[
    Todo(id: 'todo-0', description: 'hello'),
    Todo(id: 'todo-1', description: 'hola'),
    Todo(id: 'todo-2', description: 'bonjour'),
  ],
);
final refTodoListFilter = Provided(
  debugName: 'todoListFilter',
  (_) => TodoListFilter.all,
);
final refHomeStateLogic = Provided(
  debugName: 'homeStateLogic',
  (_) => HomeStateLogic(),
);

class HomeStateLogic with StateLogic {
  HomeStateLogic();

  TodoListFilter get filter => read(refTodoListFilter);
  set filter(TodoListFilter value) => write(refTodoListFilter, value);

  void add(String description) {
    _updateTodos(
      (list) => [
        ...list,
        Todo(description: description),
      ],
    );
  }

  void toggle(String id) {
    _updateTodo(
      id,
      (todo) => Todo(
        id: todo.id,
        description: todo.description,
        completed: !todo.completed,
      ),
    );
  }

  void editTodo({required String id, required String description}) {
    _updateTodo(
      id,
      (todo) => Todo(
        id: todo.id,
        description: description,
        completed: todo.completed,
      ),
    );
  }

  void remove(String id) {
    _updateTodos(
      (list) => [
        for (final Todo todo in list)
          if (todo.id != id) todo,
      ],
    );
  }

  void _updateTodos(List<Todo> Function(List<Todo>) updater) {
    update(refTodoList, updater);
  }

  void _updateTodo(String id, Todo Function(Todo) updater) {
    _updateTodos(
      (List<Todo> list) => [
        for (final Todo todo in list)
          if (todo.id == id) updater(todo) else todo,
      ],
    );
  }
}
