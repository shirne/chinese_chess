import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:chinese_chess/models/game_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'generated/l10n.dart';
import 'widgets/game_wrapper.dart';
import 'game_board.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final gamer = GameManager();
  await gamer.init();
  runApp(const MainApp());
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    doWhenWindowReady(() {
      final win = appWindow;
      const initialSize = Size(1024, 720);
      win.minSize = initialSize;
      win.size = initialSize;
      win.alignment = Alignment.center;
      win.show();
    });
  }
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      onGenerateTitle: (BuildContext context) {
        if (!kIsWeb &&
            (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
          appWindow.title = S.of(context).app_title;
        }
        return S.of(context).app_title;
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        S.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('zh', 'CN'),
      ],
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const GameWrapper(
        isMain: true,
        child: GameBoard(),
      ),
    );
  }
}
