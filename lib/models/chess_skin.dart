

import 'dart:convert';
import 'dart:io';
import 'package:universal_html/html.dart' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'chess_pos.dart';

class ChessSkin{
  String folder = "";

  double width = 521;
  double height = 577;
  double size = 57;
  Offset offset = Offset(4, 3);

  String board = "board.jpg";
  String blank = "blank.gif";
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

  ValueNotifier<bool> readyNotifier;

  ChessSkin(this.folder){
    readyNotifier = ValueNotifier(false);
    String jsonfile = "assets/skins/$folder/config.json";
    if(kIsWeb){
      html.HttpRequest.getString(jsonfile).then((String fileContents) {
        loadJson(fileContents);
      }).catchError((error) {
        print(error.toString());
        readyNotifier.value = true;
      });
    }else {
      File file = File(jsonfile);
      file.exists().then((bool has) {
        if (has) {
          file.readAsString().then(loadJson);
        } else {
          print('$jsonfile not exists');
          readyNotifier.value = true;
        }
      });
    }
  }

  loadJson(String content){
    Map<String, dynamic> json = JsonDecoder().convert(content);
    json.forEach((key, value) {
      switch(key){
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

  String get boardImage{
    return "assets/skins/$folder/$board";
  }

  String getRedChess(String code){
    if(!redMap.containsKey(code.toUpperCase())){
      print('Code error: $code');
      return "assets/skins/$folder/$blank";
    }
    return "assets/skins/$folder/${redMap[code.toUpperCase()]}";
  }
  String getBlackChess(String code){
    if(!blackMap.containsKey(code.toLowerCase())){
      print('Code error: $code');
      return "assets/skins/$folder/$blank";
    }
    return "assets/skins/$folder/${blackMap[code.toLowerCase()]}";
  }

  Alignment getAlign(ChessPos pos){
    return Alignment(
      ((pos.x * size + offset.dx) * 2 ) / (width - size) - 1,
      (((9 - pos.y) * size + offset.dy) * 2 ) / (height - size) - 1,
    );
  }

}