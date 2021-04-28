// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:chinese_chess/models/chess_manual.dart';
import 'package:chinese_chess/models/chess_fen.dart';
import 'package:chinese_chess/models/chess_pos.dart';

void main() {
  test('test Pos', (){
    print(1 ~/ 2);
    print(1 ~/ 3);
    print(1 ~/ 4);
    print(1 ~/ 5);

    print(2 ~/ 1);
    print(2 ~/ 2);
    print(2 ~/ 3);
    print(2 ~/ 4);
    print(2 ~/ 5);

    ChessPos from = ChessPos.fromCode('a0');

    print(from);
    ChessPos to = from;
    print(to);
    from.x = 2;
    print([from, to]);
    from = ChessPos.fromCode('h9');
    print([from, to]);
  });
  test('test Fen', (){
    ChessFen fen = ChessFen();

    print(fen.fen);

  });

  test('test ChessManual', () {
    ChessFen fen = ChessFen();
    String move = 'h0g2';
    String chineseMove = fen.toChineseString(move);
    print(chineseMove);
    expect(chineseMove, '马二进三');
    print(fen.toPositionString(0,chineseMove));

    fen.move(move);
    print(fen);

    move = 'h7e7';
    chineseMove = fen.toChineseString(move);
    print(chineseMove);
    expect(chineseMove, '炮8平5');
    print(fen.toPositionString(1,chineseMove));

    fen.move(move);
    print(fen);

    move = 'b2e2';
    chineseMove = fen.toChineseString(move);
    print(chineseMove);
    expect(chineseMove, '砲八平五');
    print(fen.toPositionString(0,chineseMove));

    fen.move(move);
    print(fen);

    move = 'h9g7';
    chineseMove = fen.toChineseString(move);
    print(chineseMove);
    expect(chineseMove, '马8进7');
    print(fen.toPositionString(1,chineseMove));

    fen.move(move);
    print(fen);


    fen.fen = '4k4/3P1P3/4P4/3P1P3/9/9/9/9/9/4K4 w - - 0 1';
    move = 'f8e8';
    chineseMove = fen.toChineseString(move);
    print(chineseMove);
    expect(chineseMove, '一兵平五');
    print(fen.toPositionString(0,chineseMove));

    move = 'f6e6';
    chineseMove = fen.toChineseString(move);
    print(chineseMove);
    expect(chineseMove, '二兵平五');
    print(fen.toPositionString(0,chineseMove));

    move = 'e7e8';
    chineseMove = fen.toChineseString(move);
    print(chineseMove);
    expect(chineseMove, '兵五进一');
    print(fen.toPositionString(0,chineseMove));

    move = 'd8e8';
    chineseMove = fen.toChineseString(move);
    print(chineseMove);
    expect(chineseMove, '三兵平五');
    print(fen.toPositionString(0,chineseMove));

    move = 'd6e6';
    chineseMove = fen.toChineseString(move);
    print(chineseMove);
    expect(chineseMove, '四兵平五');
    print(fen.toPositionString(0,chineseMove));

  });
}
