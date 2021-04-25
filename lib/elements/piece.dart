import 'dart:io';

import 'package:flutter/material.dart';

import '../chess.dart';
import '../models/chess_map.dart';

class Piece extends StatelessWidget {
  final ChessItem item;
  final bool isActive;

  const Piece({Key key, this.item, this.isActive = false}) : super(key: key);

  Widget blankWidget(ChessState chess){

    double size = chess.pieceSize;

    return GestureDetector(
      onTap: (){
        chess.setNext(item);
      },
      child: Container(
        width: size,
        height: size,
        decoration: this.isActive ? BoxDecoration(
            border: Border.all(color: Colors.blueAccent)
        ):BoxDecoration(
            color: Colors.transparent
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ChessState chess = context.findAncestorStateOfType<ChessState>();
    double size = chess.pieceSize;

    return this.item.isBlank ? blankWidget(chess) : GestureDetector(
      onTap: (){
        chess.setActive(item);
      },
      child: Container(
        width: size,
        height: size,
        decoration: this.isActive ? BoxDecoration(
            border: Border.all(color: Colors.blueAccent)
        ):null,
        child: Image.asset('assets/skins/${chess.widget.skin}/${item.team}${item.code}.gif'),
      ),
    );
  }
}

