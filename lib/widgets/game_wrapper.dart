import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../global.dart';
import '../models/game_manager.dart';

class GameWrapper extends StatefulWidget {
  final Widget child;
  final bool isMain;

  const GameWrapper({super.key, required this.child, this.isMain = false});

  static GameWrapperState of(BuildContext context) {
    return context.findAncestorStateOfType<GameWrapperState>()!;
  }

  @override
  State<GameWrapper> createState() => GameWrapperState();
}

class GameWrapperState extends State<GameWrapper> with WindowListener {
  final GameManager gamer = GameManager();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (widget.isMain) {
      gamer.dispose();
    }
    super.dispose();
  }

  @override
  void onWindowClose() {
    logger.info('gamer destroy');
    gamer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (size.width < 541) {
      gamer.scale = (size.width - 20) / 521;
    } else {
      gamer.scale = 1;
    }
    return widget.child;
  }
}
