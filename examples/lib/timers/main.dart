import 'package:examples/timers/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:state_watcher/state_watcher.dart';

void main() {
  runApp(const TimersApp());
}

class TimersApp extends StatelessWidget {
  const TimersApp({
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
        home: const HomeScreen(),
      ),
    );
  }
}
