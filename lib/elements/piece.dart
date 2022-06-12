import 'package:flutter/material.dart';

import '../models/chess_item.dart';
import '../models/game_manager.dart';
import '../widgets/game_wrapper.dart';

class Piece extends StatelessWidget {
  final ChessItem item;
  final bool isActive;
  final bool isAblePoint;
  final bool isHover;

  const Piece(
      {Key? key,
      required this.item,
      this.isActive = false,
      this.isHover = false,
      this.isAblePoint = false})
      : super(key: key);

  Widget blankWidget(GameManager gamer) {
    double size = gamer.skin.size;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: Colors.transparent),
    );
  }

  @override
  Widget build(BuildContext context) {
    GameManager gamer =
        context.findAncestorStateOfType<GameWrapperState>()!.gamer;
    String team = item.team == 0 ? 'r' : 'b';

    return item.isBlank
        ? blankWidget(gamer)
        : AnimatedContainer(
            width: gamer.skin.size * gamer.scale,
            height: gamer.skin.size * gamer.scale,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutQuint,
            transform: isHover
                ? (Matrix4.translationValues(-4, -4, -4))
                : (Matrix4.translationValues(0, 0, 0)),
            transformAlignment: Alignment.topCenter,
            decoration: (isHover)
                ? BoxDecoration(
                    boxShadow: const [
                        BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, .1),
                            offset: Offset(2, 3),
                            blurRadius: 1,
                            spreadRadius: 0),
                        BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, .1),
                            offset: Offset(4, 6),
                            blurRadius: 2,
                            spreadRadius: 2)
                      ],
                    //border: Border.all(color: Color.fromRGBO(255, 255, 255, .7), width: 2),
                    borderRadius:
                        BorderRadius.all(Radius.circular(gamer.skin.size / 2)))
                : BoxDecoration(
                    boxShadow: const [
                        BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, .2),
                            offset: Offset(2, 2),
                            blurRadius: 1,
                            spreadRadius: 0),
                        BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, .1),
                            offset: Offset(3, 3),
                            blurRadius: 1,
                            spreadRadius: 1),
                      ],
                    border: isActive
                        ? Border.all(
                            color: Colors.white54,
                            width: 2,
                            style: BorderStyle.solid)
                        : null,
                    borderRadius:
                        BorderRadius.all(Radius.circular(gamer.skin.size / 2))),
            child: Stack(
              children: [
                Image.asset(team == 'r'
                    ? gamer.skin.getRedChess(item.code)
                    : gamer.skin.getBlackChess(item.code)),
              ],
            ),
          );
  }
}
