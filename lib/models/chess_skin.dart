

import 'package:flutter/material.dart';

import 'chess_pos.dart';

class ChessSkin{
  String folder = "";

  double width = 521;
  double height = 577;
  double size = 57;
  Offset offset = Offset(4, 3);

  String board = "board.jpg";
  Map<String, String> redMap = {
    "K": "rk.gif",
    "A": "ra.gif",
    "B": "rb.gif",
    "C": "rc.gif",
    "N": "rn.gif",
    "R": "rr.gif",
    "P": "rp.gif"
  };
  Map<String, String> blackMap = {
    "k": "bk.gif",
    "a": "ba.gif",
    "b": "bb.gif",
    "c": "bc.gif",
    "n": "bn.gif",
    "r": "br.gif",
    "p": "bp.gif"
  };

  ChessSkin(this.folder);

  String get boardImage{
    return "assets/skins/$folder/$board";
  }

  String getRedChess(String code){
    return "assets/skins/$folder/${redMap[code.toUpperCase()]}";
  }
  String getBlackChess(String code){
    return "assets/skins/$folder/${blackMap[code.toLowerCase()]}";
  }

  Alignment getAlign(ChessPos pos){
    return Alignment(
      ((pos.x * size + offset.dx) * 2 ) / (width - size) - 1,
      (((9 - pos.y) * size + offset.dy) * 2 ) / (height - size) - 1,
    );
  }
}