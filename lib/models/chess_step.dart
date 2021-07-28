
import 'chess_fen.dart';

class ChessStep{

  // 当前回合数
  int round = 0;

  // 落着选手
  int hand = 0;

  // 行子 仅作备用
  String code;

  // 着法
  String move;

  // 落着备注
  String description;

  // 该步行走前的状态
  String fen;

  // 该步行走前的力子位置图
  String fenPosition;

  // 该步是否吃子
  bool isEat = false;

  // 该步是否将军
  bool isCheckMate = false;

  ChessStep(this.hand, this.move, {this.code = '', this.fen = '', this.fenPosition = '', this.description = '', this.isEat = false, this.isCheckMate = false, this.round = 0}){
    if(this.code.isEmpty && fen.isNotEmpty){
      List<String> rows = fen.split('/').reversed.toList();
      String row = rows[int.parse(move[1])];
      row = row.replaceAllMapped(RegExp(r'\d'), (i){
        return List.filled(int.parse(i[0]!), '0').join('');
      });
      int col = move.codeUnitAt(0) - ChessFen.colIndexBase;
      this.code = row[col];
    }
  }


  @override
  String toString() {
    String moveString = '$code $move ';
    if(isEat){
      moveString += '吃 ';
    }
    if(isCheckMate){
      moveString += '将 ';
    }
    return moveString;
  }

  String _chineseString = '';
  String toChineseString() {
    if(_chineseString.isNotEmpty){
      return _chineseString;
    }

    _chineseString = ChessFen(fen).toChineseString(move);

    return _chineseString;
  }
}