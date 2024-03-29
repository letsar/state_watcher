import 'package:examples/todos/home/home_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:state_watcher/state_watcher.dart';

void main() {
  runApp(const TodosApp());
}

class TodosApp extends StatelessWidget {
  const TodosApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StateStore(
      observers: const [MyObserver()],
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}

class MyObserver extends StateObserver {
  const MyObserver();

  @override
  void didStateCreated<T>(Ref<T> ref, T value) {
    if (kDebugMode) {
      print('[MyObserver] didStateCreated: $ref with value: $value}');
    }
  }

  @override
  void didStateUpdated<T>(Ref<T> ref, T oldValue, T newValue) {
    if (kDebugMode) {
      print('[MyObserver] didStateUpdated: $ref: from $oldValue to $newValue');
    }
  }

  @override
  void didStateDeleted<T>(Ref<T> ref) {
    if (kDebugMode) {
      print('[MyObserver] didStateUpdated: $ref');
    }
  }
}
