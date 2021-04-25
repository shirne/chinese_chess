

import 'dart:io';

import 'package:flutter/material.dart';

import '../chess.dart';

class Board extends StatefulWidget{

  const Board({Key key}) : super(key: key);

  @override
  State<Board> createState() => BoardState();
}

class BoardState extends State<Board> {
  @override
  Widget build(BuildContext context) {
    ChessState chess = context.findAncestorStateOfType<ChessState>();
    return SizedBox(
      width: chess.boardWidth,
      height: chess.boardHeight,
      child: Image.asset(
          'assets/skins/${chess.widget.skin}/board.jpg'
      ),
    );
  }
}