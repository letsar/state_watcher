import 'package:examples/conditional_watch/main.dart';
import 'package:examples/counter/main.dart';
import 'package:examples/pub/main.dart';
import 'package:examples/shopper/main.dart';
import 'package:examples/todos/main.dart';
import 'package:examples/user_devices/main.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExamplesApp());
}

class ExamplesApp extends StatelessWidget {
  const ExamplesApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: _Apps(),
    );
  }
}

class _Apps extends StatelessWidget {
  const _Apps();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: const [
          _AppTile(title: 'Counter', builder: _counterApp),
          _AppTile(title: 'ConditionalWatch', builder: _conditionalWatchApp),
          _AppTile(title: 'Pub', builder: _pupApp),
          _AppTile(title: 'Shopper', builder: _shopperApp),
          _AppTile(title: 'Todos', builder: _todosApp),
          _AppTile(title: 'UserDevices', builder: _userDevicesApp),
        ],
      ),
    );
  }
}

class _AppTile extends StatelessWidget {
  const _AppTile({
    required this.title,
    required this.builder,
  });

  final String title;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: builder,
          ),
        );
      },
    );
  }
}

Widget _counterApp(BuildContext context) {
  return const CounterApp();
}

Widget _conditionalWatchApp(BuildContext context) {
  return const ConditionalWatchApp();
}

Widget _pupApp(BuildContext context) {
  return const PubApp();
}

Widget _shopperApp(BuildContext context) {
  return const ShopperApp();
}

Widget _todosApp(BuildContext context) {
  return const TodosApp();
}

Widget _userDevicesApp(BuildContext context) {
  return const UserDevicesApp();
}
