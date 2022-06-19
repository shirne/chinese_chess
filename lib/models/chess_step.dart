import 'chess_fen.dart';

class ChessStep {
  // 当前回合数
  final int round;

  // 落着选手
  final int hand;

  // 行子 仅作备用
  final String code;

  // 着法
  final String move;

  // 落着备注
  final String description;

  // 该步行走前的状态
  final String fen;

  // 该步行走前的力子位置图
  final String fenPosition;

  // 该步是否吃子
  final bool isEat;

  // 该步是否将军
  final bool isCheckMate;

  ChessStep(
    this.hand,
    this.move, {
    String? code = '',
    this.fen = '',
    this.fenPosition = '',
    this.description = '',
    this.isEat = false,
    this.isCheckMate = false,
    this.round = 0,
  }) : code = code ?? getCode(fen, move);

  static String getCode(String fen, String pos) {
    List<String> rows = fen.split('/').reversed.toList();
    String row = rows[int.parse(pos[1])];
    row = row.replaceAllMapped(RegExp(r'\d'), (i) {
      return List.filled(int.parse(i[0]!), '0').join('');
    });
    int col = pos.codeUnitAt(0) - ChessFen.colIndexBase;
    return row[col];
  }

  @override
  String toString() {
    String moveString = '$code $move ';
    if (isEat) {
      moveString += '吃 ';
    }
    if (isCheckMate) {
      moveString += '将 ';
    }
    return moveString;
  }

  String _chineseString = '';
  String toChineseString() {
    if (_chineseString.isNotEmpty) {
      return _chineseString;
    }

    _chineseString = ChessFen(fen).toChineseString(move);

    return _chineseString;
  }
}
