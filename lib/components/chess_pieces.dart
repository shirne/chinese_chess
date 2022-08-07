import 'package:cchess/cchess.dart';
import 'package:flutter/material.dart';

import '../models/game_event.dart';
import '../models/game_manager.dart';
import 'piece.dart';

class ChessPieces extends StatefulWidget {
  final List<ChessItem> items;
  final ChessItem? activeItem;

  const ChessPieces({
    Key? key,
    required this.items,
    this.activeItem,
  }) : super(key: key);

  @override
  State<ChessPieces> createState() => _ChessPiecesState();
}

class _ChessPiecesState extends State<ChessPieces> {
  late GameManager gamer = GameManager.instance;
  int curTeam = -1;

  @override
  void initState() {
    super.initState();
    initGamer();
  }

  initGamer() {
    gamer.on<GamePlayerEvent>(onChangePlayer);
    curTeam = gamer.curHand;
  }

  @override
  void dispose() {
    gamer.off<GamePlayerEvent>(onChangePlayer);
    super.dispose();
  }

  void onChangePlayer(GameEvent event) {
    if (!mounted) return;
    setState(() {
      curTeam = event.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    initGamer();
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: widget.items.map<Widget>((ChessItem item) {
        bool isActive = false;
        bool isHover = false;
        if (item.isBlank) {
          //return;
        } else if (widget.activeItem != null) {
          if (widget.activeItem!.position == item.position) {
            isActive = true;
            if (curTeam == item.team) {
              isHover = true;
            }
          }
        }

        return AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutQuint,
          alignment: gamer.skin.getAlign(item.position),
          child: SizedBox(
            width: gamer.skin.size * gamer.scale,
            height: gamer.skin.size * gamer.scale,
            //transform: isActive && lastPosition.isEmpty ? Matrix4(1, 0, 0, 0.0, -0.105 * skewStepper, 1 - skewStepper*0.1, 0, -0.004 * skewStepper, 0, 0, 1, 0, 0, 0, 0, 1) : Matrix4.identity(),
            child: Piece(
              item: item,
              isHover: isHover,
              isActive: isActive,
            ),
          ),
        );
      }).toList(),
    );
  }
}
