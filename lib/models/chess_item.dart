

import 'chess_fen.dart';
import 'chess_pos.dart';

class ChessItem{
  String code;
  ChessPos position;

  ChessItem(this.code, {this.position});

  int get team{
    if(isBlank){
      return -1;
    }
    return code.codeUnitAt(0) < ChessFen.colIndexBase ? 0 : 1;
  }

  bool get isBlank{
    return code == '0';
  }

  @override
  String toString() {
    return "$code@${position == null ? '' : position.toCode()}";
  }
}