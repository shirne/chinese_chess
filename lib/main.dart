import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'generated/l10n.dart';
import 'widgets/game_wrapper.dart';
import 'game_board.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: '',
        onGenerateTitle: (BuildContext context){
          return S.of(context).app_title;
        },
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        S.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('zh', 'CN'),
      ],
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
