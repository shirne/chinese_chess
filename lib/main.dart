import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'package:window_manager/window_manager.dart';

import 'global.dart';
import 'l10n/generated/app_localizations.dart';
import 'models/game_manager.dart';
import 'widgets/game_wrapper.dart';
import 'game_board.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(1024, 720),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
    windowManager.addListener(MainWindowListener());
  }
  final gamer = GameManager();
  await gamer.init();
  runApp(const MainApp());
}

class MainWindowListener extends WindowListener {
  @override
  void onWindowClose() {
    GameManager.instance.engine?.dispose();
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
          windowManager.setTitle(context.l10n.app_title);
        }
        return context.l10n.app_title;
      },
      navigatorKey: MyDialog.navigatorKey,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ShirneDialogLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('zh', 'CN'),
      ],
      theme: AppTheme.createTheme(),
      highContrastTheme: AppTheme.createTheme(isHighContrast: true),
      darkTheme: AppTheme.createTheme(isDark: true),
      highContrastDarkTheme: AppTheme.createTheme(
        isDark: true,
        isHighContrast: true,
      ),
      home: const GameWrapper(
        isMain: true,
        child: GameBoard(),
      ),
    );
  }
}
