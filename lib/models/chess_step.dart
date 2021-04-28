
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

  // 该步是否吃子
  bool isEat = false;

  ChessStep(int hand,String code,String move, {description = '', isEat = false, round = 0, fen = ''}){
    this.hand = hand;
    this.code = code;
    this.move = move;
    this.isEat = isEat;
    this.round = round;
    this.fen = fen;


    if(this.code.isEmpty && fen.isNotEmpty){
      List<String> rows = fen.split('/');
      String row = rows[int.parse(move[3])];
      row = row.replaceAllMapped(RegExp(r'\d'), (i){
        return List.filled(int.parse(i[0]), '0').join('');
      });
      int col = move.codeUnitAt(2) - 'a'.codeUnitAt(0);
      this.code = row[col];
    }
  }


  @override
  String toString() {
    return '$code $move '+(isEat?'吃':'');
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