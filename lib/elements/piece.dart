

import 'package:flutter/material.dart';

import '../chess.dart';
import '../models/chess_item.dart';

class Piece extends StatelessWidget {
  final ChessItem item;
  final bool isActive;
  final bool isAblePoint;

  const Piece({Key key, this.item, this.isActive = false, this.isAblePoint = false})
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

              decoration: this.isActive
                  ? BoxDecoration(
                    border: Border.all(color: Color.fromRGBO(255, 255, 255, .7), width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(chess.gamer.skin.size / 2))
                  )
                  : null,
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
