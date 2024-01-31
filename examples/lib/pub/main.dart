import 'package:examples/pub/features/search/views/search_page.dart';
import 'package:flutter/material.dart';
import 'package:state_watcher/state_watcher.dart';

void main() {
  runApp(const PubApp());
}

class PubApp extends StatelessWidget {
  const PubApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const StateScope(
      child: MaterialApp(
        home: SearchPage(),
      ),
    );
  }
}
