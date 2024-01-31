import 'package:examples/todos/home/home_state_logic.dart';
import 'package:flutter/material.dart';
import 'package:state_watcher/state_watcher.dart';

import '../entities/todo.dart';

final refCurrentTodo = Variable<Todo>.undefined(debugName: 'currentTodo');
final refUncompletedTodosCount = Computed(
  debugName: 'uncompletedTodosCount',
  (watch) => watch(refTodoList).where((todo) => !todo.completed).length,
);
final refFilteredTodos = Computed<List<Todo>>(
  debugName: 'filteredTodos',
  (watch) {
    final TodoListFilter filter = watch(refTodoListFilter);
    final List<Todo> todos = watch(refTodoList);

    switch (filter) {
      case TodoListFilter.active:
        return todos.where((todo) => !todo.completed).toList();
      case TodoListFilter.completed:
        return todos.where((todo) => todo.completed).toList();
      case TodoListFilter.all:
      default:
        return todos;
    }
  },
);

class HomePage extends WatcherStatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  late final TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Todo> todos = scope.watch(refFilteredTodos);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          children: [
            const Title(),
            TextField(
              controller: textEditingController,
              decoration: const InputDecoration(
                labelText: 'What needs to be done?',
              ),
              onSubmitted: (value) {
                scope.read(refHomeStateLogic).add(value);
                textEditingController.clear();
              },
            ),
            const SizedBox(height: 42),
            const Toolbar(),
            if (todos.isNotEmpty) const Divider(height: 0),
            for (int i = 0; i < todos.length; i++) ...[
              if (i > 0) const Divider(height: 0),
              Dismissible(
                key: ValueKey(todos[i].id),
                onDismissed: (_) {
                  scope.read(refHomeStateLogic).remove(todos[i].id);
                },
                child: StateScope(
                  overrides: {
                    refCurrentTodo.overrideWithValue(todos[i]),
                  },
                  child: const TodoItem(),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}

class Title extends StatelessWidget {
  const Title({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'todos',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color.fromARGB(38, 47, 47, 247),
        fontSize: 100,
        fontWeight: FontWeight.w100,
        fontFamily: 'Helvetica Neue',
      ),
    );
  }
}

class Toolbar extends WatcherStatelessWidget {
  const Toolbar({super.key});

  @override
  Widget build(BuildContext context, BuildScope scope) {
    final int count = scope.watch(refUncompletedTodosCount);

    return Material(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '$count items left',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const TodoFilterTab(
            tooltip: 'All todos',
            label: 'All',
            filter: TodoListFilter.all,
          ),
          const TodoFilterTab(
            tooltip: 'Only uncompleted todos',
            label: 'Active',
            filter: TodoListFilter.active,
          ),
          const TodoFilterTab(
            tooltip: 'Only completed todos',
            label: 'Completed',
            filter: TodoListFilter.completed,
          ),
        ],
      ),
    );
  }
}

class TodoFilterTab extends WatcherStatelessWidget {
  const TodoFilterTab({
    super.key,
    required this.tooltip,
    required this.filter,
    required this.label,
  });

  final String tooltip;
  final TodoListFilter filter;
  final String label;

  static final _refIsSelected = Computed.withParameter(
    (watch, TodoListFilter filter) {
      final TodoListFilter currentFilter = watch(refTodoListFilter);
      return currentFilter == filter;
    },
    debugName: 'isSelected',
  );

  @override
  Widget build(BuildContext context, BuildScope scope) {
    final isSelected = scope.watch(_refIsSelected(filter));

    return Tooltip(
      message: tooltip,
      child: FilledButton(
        onPressed: () => scope.read(refHomeStateLogic).filter = filter,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue : null,
          ),
        ),
      ),
    );
  }
}

class TodoItem extends WatcherStatefulWidget {
  const TodoItem({
    super.key,
  });

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  late final FocusNode itemFocusNode;
  late final FocusNode textFieldFocusNode;
  late final TextEditingController textEditingController;
  int rebuild = 0;

  @override
  void initState() {
    super.initState();
    itemFocusNode = FocusNode();
    textFieldFocusNode = FocusNode();
    textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    itemFocusNode.dispose();
    textFieldFocusNode.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Todo todo = scope.watch(refCurrentTodo);
    final isFocused = itemFocusNode.hasFocus;

    return Material(
      color: Colors.white,
      elevation: 6,
      child: Focus(
        focusNode: itemFocusNode,
        onFocusChange: (focused) {
          if (focused) {
            textEditingController.text = todo.description;
          } else {
            scope.read(refHomeStateLogic).editTodo(
                  id: todo.id,
                  description: textEditingController.text,
                );
          }
          setState(() {});
        },
        child: ListTile(
          onTap: () {
            itemFocusNode.requestFocus();
            textFieldFocusNode.requestFocus();
          },
          leading: Checkbox(
            value: todo.completed,
            onChanged: (value) {
              scope.read(refHomeStateLogic).toggle(todo.id);
            },
          ),
          title: isFocused
              ? TextField(
                  autofocus: true,
                  focusNode: textFieldFocusNode,
                  controller: textEditingController,
                )
              : Text(todo.description),
        ),
      ),
    );
  }
}
