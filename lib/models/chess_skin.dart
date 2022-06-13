import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';

import 'chess_pos.dart';
import 'game_manager.dart';

class ChessSkin {
  GameManager manager;
  String folder = "";

  double width = 521;
  double height = 577;
  double size = 57;
  Offset offset = const Offset(4, 3);

  String board = "board.jpg";
  String blank = "blank.png";
  Map<String, String> redMap = {
    "K": "rk.gif",
    "A": "ra.png",
    "B": "rb.png",
    "C": "rc.png",
    "N": "rn.png",
    "R": "rr.png",
    "P": "rp.png"
  };
  Map<String, String> blackMap = {
    "k": "bk.png",
    "a": "ba.png",
    "b": "bb.png",
    "c": "bc.png",
    "n": "bn.png",
    "r": "br.png",
    "p": "bp.png"
  };

  late ValueNotifier<bool> readyNotifier;

  ChessSkin(this.folder, this.manager) {
    readyNotifier = ValueNotifier(false);
    String jsonfile = "assets/skins/$folder/config.json";
    rootBundle.loadString(jsonfile).then((String fileContents) {
      loadJson(fileContents);
    }).catchError((error) {
      print(error.toString());
      readyNotifier.value = true;
    });
  }

  loadJson(String content) {
    Map<String, dynamic> json = jsonDecode(content);
    json.forEach((key, value) {
      switch (key) {
        case 'width':
          width = value.toDouble();
          break;
        case 'height':
          height = value.toDouble();
          break;
        case 'size':
          size = value.toDouble();
          break;
        case 'board':
          board = value.toString();
          break;
        case 'blank':
          blank = value.toString();
          break;
        case 'offset':
          offset = Offset(value['dx'].toDouble(), value['dy'].toDouble());
          break;
        case 'red':
          redMap = value.cast<String, String>();
          break;
        case 'black':
          blackMap = value.cast<String, String>();
          break;
      }
    });
    readyNotifier.value = true;
  }

  String get boardImage => "assets/skins/$folder/$board";

  String getRedChess(String code) {
    if (!redMap.containsKey(code.toUpperCase())) {
      print('Code error: $code');
      return "assets/skins/$folder/$blank";
    }
    return "assets/skins/$folder/${redMap[code.toUpperCase()]}";
  }

  String getBlackChess(String code) {
    if (!blackMap.containsKey(code.toLowerCase())) {
      print('Code error: $code');
      return "assets/skins/$folder/$blank";
    }
    return "assets/skins/$folder/${blackMap[code.toLowerCase()]}";
  }

  Alignment getAlign(ChessPos? pos) {
    if (pos == null) {
      return const Alignment(1.2, 0);
    }
    return Alignment(
      ((pos.x * size + offset.dx) * 2) / (width - size) - 1,
      (((9 - pos.y) * size + offset.dy) * 2) / (height - size) - 1,
    );
  }
}
