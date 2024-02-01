import 'package:examples/user_devices/assigment/views/assigment_page.dart';
import 'package:flutter/material.dart';
import 'package:state_watcher/state_watcher.dart';

void main() {
  runApp(const UserDevicesApp());
}

class UserDevicesApp extends StatelessWidget {
  const UserDevicesApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StateStore(
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AssignmentPage(),
      ),
    );
  }
}
