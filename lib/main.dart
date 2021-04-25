
import 'package:flutter/material.dart';

import 'game.dart';
import 'play.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chinese chess',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameWrapper(),
    );
  }
}
