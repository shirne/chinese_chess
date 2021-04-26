
import 'package:flutter/material.dart';

import '../chess.dart';
import '../models/chess_map.dart';

class Piece extends StatelessWidget {
  final ChessItem item;
  final bool isActive;
  final bool isAblePoint;

  const Piece({Key key, this.item, this.isActive = false, this.isAblePoint = false})
      : super(key: key);

  Widget ablePoint() {
    return Center(
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.all(Radius.circular(10))),
      ),
    );
  }

  Widget blankWidget(ChessState chess) {
    double size = chess.pieceSize;

    return GestureDetector(
      onTap: () {
        chess.setNext(item);
      },
      child: Container(
        width: size,
        height: size,
        decoration: this.isActive
            ? ShapeDecoration(
          color: Colors.transparent,
          shape:  Border.all(
            color: Color.fromRGBO(255, 255, 255, .6),
            width: 2.0,
          ) + Border.all(
            color: Colors.transparent,
            width: 5.0,
          ) + Border.all(
            color: Color.fromRGBO(255, 255, 255, .8),
            width: 5.0,
          ) + Border.all(
            color: Colors.transparent,
            width: 30.0,
          ),
        )
            : BoxDecoration(color: Colors.transparent),
        child: isAblePoint ? ablePoint() : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ChessState chess = context.findAncestorStateOfType<ChessState>();
    double size = chess.pieceSize;

    return this.item.isBlank
        ? blankWidget(chess)
        : GestureDetector(
            onTap: () {
              chess.setActive(item);
            },
            child: Container(
              width: size,
              height: size,
              decoration: this.isActive
                  ? BoxDecoration(
                    border: Border.all(color: Color.fromRGBO(255, 255, 255, .7), width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(size / 2))
                  )
                  : null,
              child: Stack(
                children: [
                  Image.asset(
                      'assets/skins/${chess.widget.skin}/${item.team}${item.code}.gif'),
                  isAblePoint ? ablePoint() : SizedBox(),
                ],
              ),
            ),
          );
  }
}
