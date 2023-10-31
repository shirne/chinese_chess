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
  if (isWindow) {
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
    runApp(const MainWindowApp());
  } else {
    runApp(const MainApp());
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      onGenerateTitle: (BuildContext context) {
        if (isWindow) {
          windowManager.setTitle(context.l10n.appTitle);
        }
        return context.l10n.appTitle;
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

class MainWindowApp extends StatefulWidget {
  const MainWindowApp({super.key});

  @override
  State<MainWindowApp> createState() => _MainWindowAppState();
}

class _MainWindowAppState extends State<MainWindowApp> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    windowManager.setPreventClose(true).then((v) => setState(() {}));
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose && context.mounted) {
      final ctx = MyDialog.navigatorKey.currentContext!;
      final sure = await MyDialog.confirm(
        ctx.l10n.exitNow,
        buttonText: ctx.l10n.yesExit,
        cancelText: ctx.l10n.dontExit,
      );

      if (sure ?? false) {
        GameManager.instance.dispose();
        await windowManager.destroy();
      }
    }
  }

  @override
  void onWindowFocus() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return const MainApp();
  }
}
