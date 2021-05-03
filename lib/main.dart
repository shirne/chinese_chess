import 'package:flutter/material.dart';

import 'widgets/game_wrapper.dart';
import 'game_board.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Chinese Chess',
        onGenerateTitle: (BuildContext context){
          return 'Chinese Chess';
        },
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: GameWrapper(
          isMain: true,
          child: GameBoard(),
      ),
    );
  }
}
