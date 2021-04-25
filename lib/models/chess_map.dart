
import 'package:flutter/material.dart';

class ChessMap {
  List<ChessItem> mapData = List.generate(10*9, ( idx ) => ChessItem(isBlank: true, x:0, y:0));

  ChessMap();

  ChessMap.fromFen(String fen){
    if(fen.isNotEmpty){
      load(fen);
    }
  }

  load(String fen){
    List<String> sets = fen.split(' ');
    List<String> rows = sets[0].split('/');
    int y = 0;
    int x = 0;
    this.clear();
    rows.forEach((row) {
      row.split('').forEach( ( chr ){
        if ('abcrnkp'.indexOf(chr) > -1) {
          mapData[XYKey(x,y).hashCode] = ChessItem(team: 'b', code: chr.toLowerCase(), x:x, y:y);
        }else if ('ABCRNKP'.indexOf(chr) > -1) {
          mapData[XYKey(x,y).hashCode] = ChessItem(team: 'r', code: chr.toLowerCase(), x:x, y:y);
        }else if('123456789'.indexOf(chr) > -1){
          int blank = int.parse(chr);
          x += blank - 1;
        }
        x++;
      });
      y ++;
      x = 0;
    });
  }

  operator [](XYKey key){
    return mapData[key.hashCode];
  }

  operator []=(XYKey key, ChessItem value){
    mapData[key.hashCode] = value;
  }

  clear(){
    mapData = List.generate(10*9, (idx) => ChessItem(isBlank: true, x:idx ~/ 10, y:idx % 10));
  }

  _move(int idxFrom, int idxTo){
    if(idxFrom <0 || idxTo < 0) {
      print(['_move error', idxFrom, idxTo]);
      return;
    }
    if(idxFrom == idxTo){
      print(['_move same', idxFrom, idxTo]);
      return;
    }

    String position = mapData[idxTo].position;
    mapData[idxTo].isBlank = true;
    mapData[idxTo].position = mapData[idxFrom].position;

    mapData[idxFrom].position = position;

  }

  moveByCode(String code){
    XYKey fromKey = XYKey.fromCode(code.substring(0, 2));
    XYKey toKey = XYKey.fromCode(code.substring(2, 4));
    _move(fromKey.hashCode, toKey.hashCode);
  }

  move(ChessItem piece, ChessItem blank){
    _move(mapData.indexOf(piece), mapData.indexOf(blank));
  }

  eat(ChessItem piece,ChessItem piece2){
    _move(mapData.indexOf(piece), mapData.indexOf(piece2));
  }

  forEach(void f(XYKey key,ChessItem item)){
    for(int y = 0;y < 10; y++){
      for(int x = 0; x < 9; x++){
        f(XYKey(x, y), mapData[XYKey(x,y).hashCode]);
      }
    }
  }

}

class XYKey {
  int x;
  int y;
  XYKey(this.x, this.y);

  XYKey.fromCode(String code){
    x = code.codeUnitAt(0) - 'a'.codeUnitAt(0);
    y = 9 - int.tryParse(code[1]) ?? 0;
  }

  @override
  int get hashCode => this.x * 10 + this.y;

  operator ==(Object other){
    if(other is XYKey) {
      return this.x == other.x && this.y == other.y;
    }
    return false;
  }
}

class ChessItem{
  static int globalCode = 100;
  String position = 'a0';
  bool isBlank = true;
  String team = '';
  String code = '';
  int itemCode = 0;

  ChessItem({team = '',code = '',isBlank = false,position = '',x = -1,y = -1}){
    this.itemCode = globalCode++;
    this.team = team;
    this.code = code;
    this.isBlank = isBlank;
    if(position.isNotEmpty) {
      this.position = position;
    }else if(x > -1 && y > -1) {
      this.position = 'abcdefghijklmn'[y]+x.toString();
    }
  }

  operator ==(Object other){
    if(other is ChessItem){
      return this.itemCode == other.itemCode;
    }
    return false;
  }

  int get x{
    return int.parse(position[1]);
  }
  int get y{
    return position.codeUnitAt(0) - 'a'.codeUnitAt(0);
  }

  String toString(){
    if(this.isBlank){
      return 'ChessItem $position blank#$itemCode';
    }
    return 'ChessItem $position $team$code#$itemCode';
  }
}