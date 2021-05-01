


import 'package:flutter/material.dart';

import '../chess.dart';
import '../models/chess_item.dart';

class Piece extends StatelessWidget {
  final ChessItem item;
  final bool isActive;
  final bool isAblePoint;
  final bool isHover;

  const Piece({Key key, this.item, this.isActive = false, this.isHover = false, this.isAblePoint = false})
      : super(key: key);

  Widget blankWidget(ChessState chess) {
    double size = chess.gamer.skin.size;

    return  Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: Colors.transparent),
    );
  }

  @override
  Widget build(BuildContext context) {
    ChessState chess = context.findAncestorStateOfType<ChessState>();
    String team = item.team == 0 ? 'r' : 'b';

    return this.item.isBlank
        ? blankWidget(chess)
        :  AnimatedContainer(
              width: chess.gamer.skin.size,
              height: chess.gamer.skin.size,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOutQuint,
              transform: this.isHover ? (Matrix4.translationValues(-4, -4, -4)) : ( Matrix4.translationValues(0,0,0)),
              transformAlignment: Alignment.topCenter,
              decoration: (this.isHover)
                  ? BoxDecoration(
                    boxShadow: [
                      BoxShadow(color: Color.fromRGBO(0, 0, 0, .1),offset: Offset(2,3), blurRadius: 1, spreadRadius: 0),
                      BoxShadow(color: Color.fromRGBO(0, 0, 0, .1),offset: Offset(4,6), blurRadius: 2, spreadRadius: 2)
                    ],
                    //border: Border.all(color: Color.fromRGBO(255, 255, 255, .7), width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(chess.gamer.skin.size / 2))
                  )
                  : BoxDecoration(
                boxShadow: [
                  BoxShadow(color: Color.fromRGBO(0, 0, 0, .2),offset: Offset(2,2), blurRadius: 1, spreadRadius: 0),
                  BoxShadow(color: Color.fromRGBO(0, 0, 0, .1),offset: Offset(3,3), blurRadius: 1, spreadRadius: 1),
                ],
                  border: isActive ? Border.all(color: Colors.white54, width: 2, style: BorderStyle.solid) : null,
                  borderRadius: BorderRadius.all(Radius.circular(chess.gamer.skin.size / 2))
              ),
              child: Stack(
                children: [
                  Image.asset(
                      team == 'r'
                          ? chess.gamer.skin.getRedChess(item.code)
                          : chess.gamer.skin.getBlackChess(item.code)),
                ],
              ),
            );
  }
}
