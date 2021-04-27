// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chinese_chess/main.dart';
import 'package:chinese_chess/models/chess_manual.dart';

void main() {
  test('test ChessManual', () {
    String fen =  'rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1';
    String move = 'h0g2';
    String chineseMove = ChessManual.toChineseString(move,fen);
    print(chineseMove);
    expect(chineseMove, '马二进三');
    print(ChessManual.toPositionString(0,chineseMove,fen));

    fen = ChessManual.moveFen(fen, move);
    print(fen);

    move = 'h7e7';
    chineseMove = ChessManual.toChineseString(move,fen);
    print(chineseMove);
    expect(chineseMove, '炮8平5');
    print(ChessManual.toPositionString(1,chineseMove,fen));

    fen = ChessManual.moveFen(fen, move);
    print(fen);

    move = 'b2e2';
    chineseMove = ChessManual.toChineseString(move,fen);
    print(chineseMove);
    expect(chineseMove, '砲八平五');
    print(ChessManual.toPositionString(0,chineseMove,fen));

    fen = ChessManual.moveFen(fen, move);
    print(fen);

    move = 'h9g7';
    chineseMove = ChessManual.toChineseString(move,fen);
    print(chineseMove);
    expect(chineseMove, '马8进7');
    print(ChessManual.toPositionString(1,chineseMove,fen));

    fen = ChessManual.moveFen(fen, move);
    print(fen);


    fen = '4k4/3P1P3/4P4/3P1P3/9/9/9/9/9/4K4 w - - 0 1';
    move = 'f8e8';
    chineseMove = ChessManual.toChineseString(move,fen);
    print(chineseMove);
    expect(chineseMove, '一兵平五');
    print(ChessManual.toPositionString(0,chineseMove,fen));

    move = 'f6e6';
    chineseMove = ChessManual.toChineseString(move,fen);
    print(chineseMove);
    expect(chineseMove, '二兵平五');
    print(ChessManual.toPositionString(0,chineseMove,fen));

    move = 'e7e8';
    chineseMove = ChessManual.toChineseString(move,fen);
    print(chineseMove);
    expect(chineseMove, '兵五进一');
    print(ChessManual.toPositionString(0,chineseMove,fen));

    move = 'd8e8';
    chineseMove = ChessManual.toChineseString(move,fen);
    print(chineseMove);
    expect(chineseMove, '三兵平五');
    print(ChessManual.toPositionString(0,chineseMove,fen));

    move = 'd6e6';
    chineseMove = ChessManual.toChineseString(move,fen);
    print(chineseMove);
    expect(chineseMove, '四兵平五');
    print(ChessManual.toPositionString(0,chineseMove,fen));

  });
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {

    // Build our app and trigger a frame.
    await tester.pumpWidget(MainApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
