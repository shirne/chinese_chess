import 'package:flutter/material.dart';

import '../models/game_manager.dart';
import '../widgets/game_wrapper.dart';

/// 棋盘
class Board extends StatefulWidget {
  const Board({Key? key}) : super(key: key);

  @override
  State<Board> createState() => BoardState();
}

class BoardState extends State<Board> {
  @override
  Widget build(BuildContext context) {
    GameManager gamer =
        context.findAncestorStateOfType<GameWrapperState>()!.gamer;
    return SizedBox(
      width: gamer.skin.width,
      height: gamer.skin.height,
      child: Image.asset(gamer.skin.boardImage),
    );
  }
}
