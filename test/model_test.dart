// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:math' as Math;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chinese_chess/xqlite/position.dart';
import 'package:chinese_chess/xqlite/search.dart';
import 'package:chinese_chess/xqlite/util.dart';

import 'package:chinese_chess/models/chess_manual.dart';
import 'package:chinese_chess/models/chess_fen.dart';
import 'package:chinese_chess/models/chess_item.dart';
import 'package:chinese_chess/models/chess_pos.dart';
import 'package:chinese_chess/models/chess_rule.dart';

void main() {
  test('test IccsMove', (){
    List<String> iccs = ['b0c2','h9g7','h0g2','b9c7','f0e1','i9i8','a0a1','b7a7','g3g4','i8f8'];
    List<int> moves = [42436,22842,43466,21812,47048,19259,46019,21332,35225,18507];

    for(int i=0;i<iccs.length;i++) {
      expect(Util.iccs2Move(iccs[i]), moves[i]);
      expect(Util.move2Iccs(moves[i]), iccs[i]);
    }

  });

  test('test bookSearch', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    int startMillionSec = DateTime.now().millisecondsSinceEpoch;
    print(startMillionSec);

    Position position = Position();
    Search search = Search(position, 12);
    Position.init().then((bool v){

      print('初始化耗时：${DateTime.now().millisecondsSinceEpoch - startMillionSec}毫秒');
      startMillionSec = DateTime.now().millisecondsSinceEpoch;

      int step = 0;
      ChessFen fen = ChessFen();
      while(step < 10) {
        position.fromFen('${fen.fen} ${step % 2 == 0 ? 'w' : 'b'} - - 0 $step');
        int mvLast = search.searchMain(1000 << (1 << 1));
        String move = Util.move2Iccs(mvLast);
        print('$mvLast => $move => ${fen.toChineseString(move)}');
        fen.move(move);

        print('耗时：${DateTime.now().millisecondsSinceEpoch - startMillionSec}毫秒');
        startMillionSec = DateTime.now().millisecondsSinceEpoch;
        step++;
      }
    });
  });
  test('test ReadBook', () async{
    TestWidgetsFlutterBinding.ensureInitialized();

    ByteData data = await rootBundle.load('assets/engines/BOOK.DAT');
    print(data.lengthInBytes);

    int shortMAX = Math.pow(2, 16) - 1;
    int row = data.getUint64(0, Endian.little);

    print([row >> 33, data.getUint32(0, Endian.little) >> 1]);
    print([row >> 16 & shortMAX, data.getUint16(4, Endian.little)]);
    print([row & shortMAX, data.getUint16(6, Endian.little)]);
  });

  test('test checkMove', (){
    ChessRule rule = ChessRule.fromFen('rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1');
    expect(rule.teamCanCheck(0), false);

    rule.fen.fen = 'rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/NC5CN/9/1RBAKABR1 w - - 0 1';
    expect(rule.teamCanCheck(0), false);

    rule.fen.fen = '4ka1r1/4a1R2/4b4/pN5Np/2pC5/6P2/P3P2rP/4B4/2ncA4/2BA1K3 w - - 0 1';
    expect(rule.teamCanCheck(0), true);
    print(rule.getCheckMoves(0));

    rule.fen.fen = 'C1bak4/7R1/2n1b4/1N4p1p/2pn1r3/P2R2P2/2P1cr2P/2C1B4/4A4/2BAK4 w - - 0 1';
    expect(rule.teamCanCheck(0), true);
    print(rule.getCheckMoves(0));
  });
  
  test('test Eat', () {
    int startMillionSec = DateTime.now().millisecondsSinceEpoch;
    print(startMillionSec);
    ChessRule rule = ChessRule.fromFen('rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1');

    List<ChessItem> beEatens = rule.getBeEatenList(0);
    beEatens.forEach((item) {
      List<ChessItem> beEats = rule.getBeEatList(item.position);
      print('${item.code} <= ${beEats.map<String>((item)=>item.code).join(',')}');
    });
    print('耗时：${DateTime.now().millisecondsSinceEpoch - startMillionSec}毫秒');
    startMillionSec = DateTime.now().millisecondsSinceEpoch;

    rule.fen.fen = 'rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/NC5CN/9/1RBAKABR1 w - - 0 1';
    beEatens = rule.getBeEatenList(0);
    beEatens.forEach((item) {
      List<ChessItem> beEats = rule.getBeEatList(item.position);
      print('${item.code} <= ${beEats.map<String>((item)=>item.code).join(',')}');
    });
    print('耗时：${DateTime.now().millisecondsSinceEpoch - startMillionSec}毫秒');
    startMillionSec = DateTime.now().millisecondsSinceEpoch;

    rule.fen.fen = '4ka1r1/4a1R2/4b4/pN5Np/2pC5/6P2/P3P2rP/4B4/2ncA4/2BA1K3 w - - 0 1';
    beEatens = rule.getBeEatenList(0);
    beEatens.forEach((item) {
      List<ChessItem> beEats = rule.getBeEatList(item.position);
      print('${item.code} <= ${beEats.map<String>((item)=>item.code).join(',')}');
    });
    print('耗时：${DateTime.now().millisecondsSinceEpoch - startMillionSec}毫秒');
    startMillionSec = DateTime.now().millisecondsSinceEpoch;

    rule.fen.fen = 'C1bak4/7R1/2n1b4/1N4p1p/2pn1r3/P2R2P2/2P1cr2P/2C1B4/4A4/2BAK4 w - - 0 1';
    beEatens = rule.getBeEatenList(0);
    beEatens.forEach((item) {
      List<ChessItem> beEats = rule.getBeEatList(item.position);
      print('${item.code} <= ${beEats.map<String>((item)=>item.code).join(',')}');
    });
    print('耗时：${DateTime.now().millisecondsSinceEpoch - startMillionSec}毫秒');
    startMillionSec = DateTime.now().millisecondsSinceEpoch;
  });

  test('test rootCount', () async {
    ChessRule rule = ChessRule.fromFen('4ka1r1/4a1R2/4b4/pN5Np/2pC5/6P2/P3P2rP/4B4/2ncA4/2BA1K3 w - - 0 1');
    expect(rule.rootCount(ChessPos.fromCode('g4'), 0), 3);
    expect(rule.rootCount(ChessPos.fromCode('g4'), 1), 0);

    rule.fen.fen = 'C1bak4/7R1/2n1b4/1N4p1p/2pn1r3/P2R2P2/2P1cr2P/2C1B4/4A4/2BAK4 w - - 0 1';
    expect(rule.rootCount(ChessPos.fromCode('d5'), 0), 2);
    expect(rule.rootCount(ChessPos.fromCode('d5'), 1), 2);
    rule.fen.move('c2d2');
    expect(rule.rootCount(ChessPos.fromCode('d5'), 0), 3);
    expect(rule.rootCount(ChessPos.fromCode('d5'), 1), 2);
  });

  test('test Future', () async{
    print(DateTime.now().millisecondsSinceEpoch);
    await Future.delayed(Duration(seconds: 5));
    print(DateTime.now().millisecondsSinceEpoch);

    Future.delayed(Duration(seconds: 5)).then((value) {
      print(DateTime.now().millisecondsSinceEpoch);
    });
  });

  test('test Manual', (){

    ChessManual manual;
    ChessRule rule;
    /*manual = ChessManual(fen: '1Cbak2r1/4aR3/4b1n2/p1N1p4/2p6/3R2P2/P1P1c4/4B4/1r2A4/2B1KA3');
    manual.addMoves(['f8e8','e9e8',
      'd4d8','e8e9',
      'd8d9','e9e8',
      'd9d8','1-0']);*/

    manual = ChessManual(fen: '4k4/4a4/2P5n/5N3/9/5R3/9/9/2p2p2r/C3K4');
    manual.addMoves(['f6d7','e9d9',
      'a0d0','c1d1',
      'f4f9','e8e9',
      'd7f8','1-0']);

    manual.loadHistory(0);
    expect(manual.currentFen.fen, manual.fen);
    print('初始局面：${manual.currentFen.fen}');
    int startMillionSec = DateTime.now().millisecondsSinceEpoch;

    while(manual.hasNext) {
      print(manual.next());
      print('当前局面：${manual.currentFen.fen}');

      // 局面判断
      rule = ChessRule(manual.currentFen);
      int eTeam = manual.getMove().hand == 0 ? 1 : 0;
      if(rule.isCheck(eTeam)){
        if(rule.canParryKill(eTeam)){
          print('将军!');
        }else{
          print('绝杀!');
        }
      }
      print('耗时：${DateTime.now().millisecondsSinceEpoch - startMillionSec}毫秒');
      startMillionSec = DateTime.now().millisecondsSinceEpoch;
    }
    // 步数走完后可返回结果
    print(manual.next());
  });

  test('test isTrapped', (){
    ChessRule rule = ChessRule.fromFen('3k5/4P4/9/9/9/9/9/9/9/4K4');

    expect(rule.isTrapped(1), true);

    expect(rule.isTrapped(0), false);


    rule.fen.fen = '2bak4/1P2a4/4b4/4C4/9/9/9/9/9/5K3 w - - 0 1';

    expect(rule.isTrapped(1), true);

    expect(rule.isTrapped(0), false);
  });


  test('test isCheck', (){


    ChessRule rule = ChessRule.fromFen('rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR');
    bool isCheck = rule.isCheck(0);
    bool canParryKill;
    expect(isCheck, false);

    rule.fen.fen = 'R2akCb2/9/2N3n2/8p/4p4/6p2/P3c3P/4C1r2/4A4/1cBrK1BR1 w - - 0 1';
    print(rule.isCheck(0));
    print(rule.canParryKill(0));

    rule.fen.fen = '2b2k3/9/2N1b4/4CR3/p1p6/4N3p/P1P5P/1C7/9/R1BAKAB2';
    print(rule.isCheck(1));
    print(rule.canParryKill(1));

    rule.fen.fen = '1nRa1k2r/4P4/5R2n/p5p2/2p5p/9/P1P3P1P/N1C1C1N2/9/2BAKAB2 b - - 0 1';
    print(rule.isCheck(1));
    print(rule.canParryKill(1));

    var now = DateTime.now();
    print(now.toLocal());
    int startMillionSec = now.millisecondsSinceEpoch;

    rule.fen.fen = '4k4/4a4/2P5n/5N3/9/5R3/9/9/2p2p2r/C3K4';
    print('初始局面：${rule.fen}');
    isCheck = rule.isCheck(1);
    expect(isCheck, false);
    print('判断当前局面未将军');
    print('耗时：${DateTime.now().millisecondsSinceEpoch - startMillionSec}毫秒');
    startMillionSec = DateTime.now().millisecondsSinceEpoch;

    [
      ['f6d7','e9d9'],
      ['a0d0','c1d1'],
      ['f4f9','e8e9'],
      ['d7f8','1-0']
    ].forEach((step) {
      print(rule.fen.toChineseString(step[0]));
      rule.fen.move(step[0]);
      isCheck = rule.isCheck(1);
      expect(isCheck, true);
      canParryKill = rule.canParryKill(1);
      if(step[1] == '1-0'){
        expect(canParryKill, false);
        print('判断当前局面已绝杀');
      }else {
        expect(canParryKill, true);
        print('判断当前局面有将军且可解杀');
        print(rule.fen.toChineseString(step[1]));
        rule.fen.move(step[1]);
      }
      print('耗时：${DateTime.now().millisecondsSinceEpoch - startMillionSec}毫秒');
      startMillionSec = DateTime.now().millisecondsSinceEpoch;
    });

  });

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
    
    List<String> steps = ['f6d7','e9d9',
      'a0d0','c1d1',
      'f4f9','e8e9',
      'd7f8','1-0'];
    print(steps.take(1));
    steps.removeRange(1, steps.length);
    print(steps);

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
