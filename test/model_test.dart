// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';
import 'dart:math' as math;
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
import 'package:logging/logging.dart';

void main() {
  final logger = Logger.root;
  logger.onRecord.listen((record) {
    stdout.writeln('${record.level.name}: ${record.time}: ${record.message}');
  });

  /// xqlite 招法转换测试
  test('test IccsMove', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    List<String> iccs = [
      'b0c2',
      'h9g7',
      'h0g2',
      'b9c7',
      'f0e1',
      'i9i8',
      'a0a1',
      'b7a7',
      'g3g4',
      'i8f8'
    ];
    List<int> moves = [
      42436,
      22842,
      43466,
      21812,
      47048,
      19259,
      46019,
      21332,
      35225,
      18507
    ];

    for (int i = 0; i < iccs.length; i++) {
      expect(Util.iccs2Move(iccs[i]), moves[i]);
      expect(Util.move2Iccs(moves[i]), iccs[i]);
    }
  });

  /// 招法搜索测试
  test('test bookSearch', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    int startMillionSec = DateTime.now().millisecondsSinceEpoch;
    logger.info(startMillionSec);

    Position position = Position();
    Search search = Search(position, 12);
    Position.init().then((bool v) {
      logger.info(
          '初始化耗时：${DateTime.now().millisecondsSinceEpoch - startMillionSec}毫秒');
      startMillionSec = DateTime.now().millisecondsSinceEpoch;

      int step = 0;
      ChessFen fen = ChessFen();
      while (step < 10) {
        position.fromFen('${fen.fen} ${step % 2 == 0 ? 'w' : 'b'} - - 0 $step');
        int mvLast = search.searchMain(1000 << (1 << 1));
        String move = Util.move2Iccs(mvLast);
        logger.info('$mvLast => $move => ${fen.toChineseString(move)}');
        fen.move(move);

        logger.info(
            '耗时：${DateTime.now().millisecondsSinceEpoch - startMillionSec}毫秒');
        startMillionSec = DateTime.now().millisecondsSinceEpoch;
        step++;
      }
    });
  });

  /// 读取二进制测试
  test('test ReadBook', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    ByteData data = await rootBundle.load('assets/engines/BOOK.DAT');
    logger.info(data.lengthInBytes);

    int shortMAX = math.pow(2, 16).toInt() - 1;
    int row = data.getUint64(0, Endian.little);

    logger.info(row.toRadixString(2).padLeft(64, '0'));
    logger.info(
        data.getUint32(0, Endian.little).toRadixString(2).padLeft(32, '0'));
    logger.info(
        data.getUint32(4, Endian.little).toRadixString(2).padLeft(32, '0'));
    logger.info(
        data.getUint16(0, Endian.little).toRadixString(2).padLeft(16, '0'));
    logger.info(
        data.getUint16(2, Endian.little).toRadixString(2).padLeft(16, '0'));
    logger.info(
        data.getUint16(4, Endian.little).toRadixString(2).padLeft(16, '0'));
    logger.info(
        data.getUint16(6, Endian.little).toRadixString(2).padLeft(16, '0'));

    expect(row >> 33, data.getUint32(4, Endian.little) >> 1);
    expect(row >> 16 & shortMAX, data.getUint16(6, Endian.little));
    expect(row & shortMAX, data.getUint16(0, Endian.little));
  });

  /// 测试有没有将军的招法
  test('test checkMove', () {
    ChessRule rule = ChessRule.fromFen(
        'rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1');
    expect(rule.teamCanCheck(0), false);

    rule.fen.fen =
        'rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/NC5CN/9/1RBAKABR1 w - - 0 1';
    expect(rule.teamCanCheck(0), false);

    rule.fen.fen =
        '4ka1r1/4a1R2/4b4/pN5Np/2pC5/6P2/P3P2rP/4B4/2ncA4/2BA1K3 w - - 0 1';
    expect(rule.teamCanCheck(0), true);
    expect(rule.getCheckMoves(0), ['b6d7', 'b6c8', 'h6f7', 'g8e8']);

    rule.fen.fen =
        'C1bak4/7R1/2n1b4/1N4p1p/2pn1r3/P2R2P2/2P1cr2P/2C1B4/4A4/2BAK4 w - - 0 1';
    expect(rule.teamCanCheck(0), true);
    expect(rule.getCheckMoves(0), ['b6d7', 'b6c8', 'h8e8', 'h8h9']);
  });

  /// 测试吃子
  test('test Eat', () {
    int startMillionSec = DateTime.now().millisecondsSinceEpoch;
    logger.info(startMillionSec);
    ChessRule rule = ChessRule.fromFen(
        'rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1');

    List<ChessItem> beEatens = rule.getBeEatenList(0);
    for (var item in beEatens) {
      List<ChessItem> beEats = rule.getBeEatList(item.position);
      logger.info(
          '${item.code} <= ${beEats.map<String>((item) => item.code).join(',')}');
    }
    logger.info(
        '耗时：${DateTime.now().millisecondsSinceEpoch - startMillionSec}毫秒');
    startMillionSec = DateTime.now().millisecondsSinceEpoch;

    rule.fen.fen =
        'rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/NC5CN/9/1RBAKABR1 w - - 0 1';
    beEatens = rule.getBeEatenList(0);
    for (var item in beEatens) {
      List<ChessItem> beEats = rule.getBeEatList(item.position);
      logger.info(
          '${item.code} <= ${beEats.map<String>((item) => item.code).join(',')}');
    }
    logger.info(
        '耗时：${DateTime.now().millisecondsSinceEpoch - startMillionSec}毫秒');
    startMillionSec = DateTime.now().millisecondsSinceEpoch;

    rule.fen.fen =
        '4ka1r1/4a1R2/4b4/pN5Np/2pC5/6P2/P3P2rP/4B4/2ncA4/2BA1K3 w - - 0 1';
    beEatens = rule.getBeEatenList(0);
    for (var item in beEatens) {
      List<ChessItem> beEats = rule.getBeEatList(item.position);
      logger.info(
          '${item.code} <= ${beEats.map<String>((item) => item.code).join(',')}');
    }
    logger.info(
        '耗时：${DateTime.now().millisecondsSinceEpoch - startMillionSec}毫秒');
    startMillionSec = DateTime.now().millisecondsSinceEpoch;

    rule.fen.fen =
        'C1bak4/7R1/2n1b4/1N4p1p/2pn1r3/P2R2P2/2P1cr2P/2C1B4/4A4/2BAK4 w - - 0 1';
    beEatens = rule.getBeEatenList(0);
    for (var item in beEatens) {
      List<ChessItem> beEats = rule.getBeEatList(item.position);
      logger.info(
          '${item.code} <= ${beEats.map<String>((item) => item.code).join(',')}');
    }
    logger.info(
        '耗时：${DateTime.now().millisecondsSinceEpoch - startMillionSec}毫秒');
    startMillionSec = DateTime.now().millisecondsSinceEpoch;
  });

  /// 测试根数检查
  test('test rootCount', () async {
    ChessRule rule = ChessRule.fromFen(
        '4ka1r1/4a1R2/4b4/pN5Np/2pC5/6P2/P3P2rP/4B4/2ncA4/2BA1K3 w - - 0 1');
    expect(rule.rootCount(ChessPos.fromCode('g4'), 0), 3);
    expect(rule.rootCount(ChessPos.fromCode('g4'), 1), 0);

    rule.fen.fen =
        'C1bak4/7R1/2n1b4/1N4p1p/2pn1r3/P2R2P2/2P1cr2P/2C1B4/4A4/2BAK4 w - - 0 1';
    expect(rule.rootCount(ChessPos.fromCode('d5'), 0), 2);
    expect(rule.rootCount(ChessPos.fromCode('d5'), 1), 2);
    rule.fen.move('c2d2');
    expect(rule.rootCount(ChessPos.fromCode('d5'), 0), 3);
    expect(rule.rootCount(ChessPos.fromCode('d5'), 1), 2);
  });

  test('test Future', () async {
    logger.info(DateTime.now().millisecondsSinceEpoch);
    await Future.delayed(const Duration(seconds: 5));
    logger.info(DateTime.now().millisecondsSinceEpoch);

    Future.delayed(const Duration(seconds: 5)).then((value) {
      logger.info(DateTime.now().millisecondsSinceEpoch);
    });
  });

  /// 测试绝杀局面
  test('test Manual', () {
    ChessManual manual;
    ChessRule rule;
    /*manual = ChessManual(fen: '1Cbak2r1/4aR3/4b1n2/p1N1p4/2p6/3R2P2/P1P1c4/4B4/1r2A4/2B1KA3');
    manual.addMoves(['f8e8','e9e8',
      'd4d8','e8e9',
      'd8d9','e9e8',
      'd9d8','1-0']);*/

    manual = ChessManual(fen: '4k4/4a4/2P5n/5N3/9/5R3/9/9/2p2p2r/C3K4');
    manual.addMoves(
        ['f6d7', 'e9d9', 'a0d0', 'c1d1', 'f4f9', 'e8e9', 'd7f8', '1-0']);

    manual.loadHistory(0);
    expect(manual.currentFen.fen, manual.fen);
    logger.info('初始局面：${manual.currentFen.fen}');
    int startMillionSec = DateTime.now().millisecondsSinceEpoch;

    while (manual.hasNext) {
      logger.info(manual.next());
      logger.info('当前局面：${manual.currentFen.fen}');

      // 局面判断
      rule = ChessRule(manual.currentFen);
      int eTeam = manual.getMove()!.hand == 0 ? 1 : 0;
      if (rule.isCheck(eTeam)) {
        if (rule.canParryKill(eTeam)) {
          logger.info('将军!');
        } else {
          logger.info('绝杀!');
        }
      }
      logger.info(
          '耗时：${DateTime.now().millisecondsSinceEpoch - startMillionSec}毫秒');
      startMillionSec = DateTime.now().millisecondsSinceEpoch;
    }
    // 步数走完后可返回结果
    logger.info(manual.next());
  });

  /// 测试困毙局面
  test('test isTrapped', () {
    ChessRule rule = ChessRule.fromFen('3k5/4P4/9/9/9/9/9/9/9/4K4');

    expect(rule.isTrapped(1), true);

    expect(rule.isTrapped(0), false);

    rule.fen.fen = '2bak4/1P2a4/4b4/4C4/9/9/9/9/9/5K3 w - - 0 1';

    expect(rule.isTrapped(1), true);

    expect(rule.isTrapped(0), false);
  });

  /// 是否将军
  test('test isCheck', () {
    ChessRule rule = ChessRule.fromFen(
        'rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR');
    bool isCheck = rule.isCheck(0);
    bool canParryKill;
    expect(isCheck, false);

    rule.fen.fen =
        'R2akCb2/9/2N3n2/8p/4p4/6p2/P3c3P/4C1r2/4A4/1cBrK1BR1 w - - 0 1';
    assert(rule.isCheck(0));
    assert(!rule.canParryKill(0));

    rule.fen.fen = '2b2k3/9/2N1b4/4CR3/p1p6/4N3p/P1P5P/1C7/9/R1BAKAB2';
    assert(rule.isCheck(1));
    assert(!rule.canParryKill(1));

    rule.fen.fen =
        '1nRa1k2r/4P4/5R2n/p5p2/2p5p/9/P1P3P1P/N1C1C1N2/9/2BAKAB2 b - - 0 1';
    assert(rule.isCheck(1));
    assert(!rule.canParryKill(1));

    var now = DateTime.now();
    logger.info(now.toLocal());
    int startMillionSec = now.millisecondsSinceEpoch;

    rule.fen.fen = '4k4/4a4/2P5n/5N3/9/5R3/9/9/2p2p2r/C3K4';
    logger.info('初始局面：${rule.fen}');
    isCheck = rule.isCheck(1);
    expect(isCheck, false);
    logger.info('判断当前局面未将军');
    logger.info(
        '耗时：${DateTime.now().millisecondsSinceEpoch - startMillionSec}毫秒');
    startMillionSec = DateTime.now().millisecondsSinceEpoch;

    for (var step in [
      ['f6d7', 'e9d9'],
      ['a0d0', 'c1d1'],
      ['f4f9', 'e8e9'],
      ['d7f8', '1-0']
    ]) {
      logger.info(rule.fen.toChineseString(step[0]));
      rule.fen.move(step[0]);
      isCheck = rule.isCheck(1);
      expect(isCheck, true);
      canParryKill = rule.canParryKill(1);
      if (step[1] == '1-0') {
        expect(canParryKill, false);
        logger.info('判断当前局面已绝杀');
      } else {
        expect(canParryKill, true);
        logger.info('判断当前局面有将军且可解杀');
        logger.info(rule.fen.toChineseString(step[1]));
        rule.fen.move(step[1]);
      }
      logger.info(
          '耗时：${DateTime.now().millisecondsSinceEpoch - startMillionSec}毫秒');
      startMillionSec = DateTime.now().millisecondsSinceEpoch;
    }
  });

  test('test Pos', () {
    ChessPos from = ChessPos.fromCode('a0');

    logger.info(from);
    ChessPos to = from;
    logger.info(to);
    from.x = 2;
    logger.info([from, to]);
    from = ChessPos.fromCode('h9');
    logger.info([from, to]);
  });

  test('test Fen', () {
    ChessFen fen = ChessFen();

    logger.info(fen.fen);

    List<String> steps = [
      'f6d7',
      'e9d9',
      'a0d0',
      'c1d1',
      'f4f9',
      'e8e9',
      'd7f8',
      '1-0'
    ];
    logger.info(steps.take(1));
    steps.removeRange(1, steps.length);
    logger.info(steps);
  });

  /// 招法名转换
  test('test ChessManual', () {
    ChessFen fen = ChessFen();
    String move = 'h0g2';
    String chineseMove = fen.toChineseString(move);
    logger.info(chineseMove);
    expect(chineseMove, '马二进三');
    logger.info(fen.toPositionString(0, chineseMove));

    fen.move(move);
    logger.info(fen);

    move = 'h7e7';
    chineseMove = fen.toChineseString(move);
    logger.info(chineseMove);
    expect(chineseMove, '炮8平5');
    logger.info(fen.toPositionString(1, chineseMove));

    fen.move(move);
    logger.info(fen);

    move = 'b2e2';
    chineseMove = fen.toChineseString(move);
    logger.info(chineseMove);
    expect(chineseMove, '砲八平五');
    logger.info(fen.toPositionString(0, chineseMove));

    fen.move(move);
    logger.info(fen);

    move = 'h9g7';
    chineseMove = fen.toChineseString(move);
    logger.info(chineseMove);
    expect(chineseMove, '马8进7');
    logger.info(fen.toPositionString(1, chineseMove));

    fen.move(move);
    logger.info(fen);

    fen.fen = '4k4/3P1P3/4P4/3P1P3/9/9/9/9/9/4K4 w - - 0 1';
    move = 'f8e8';
    chineseMove = fen.toChineseString(move);
    logger.info(chineseMove);
    expect(chineseMove, '一兵平五');
    logger.info(fen.toPositionString(0, chineseMove));

    move = 'f6e6';
    chineseMove = fen.toChineseString(move);
    logger.info(chineseMove);
    expect(chineseMove, '二兵平五');
    logger.info(fen.toPositionString(0, chineseMove));

    move = 'e7e8';
    chineseMove = fen.toChineseString(move);
    logger.info(chineseMove);
    expect(chineseMove, '兵五进一');
    logger.info(fen.toPositionString(0, chineseMove));

    move = 'd8e8';
    chineseMove = fen.toChineseString(move);
    logger.info(chineseMove);
    expect(chineseMove, '三兵平五');
    logger.info(fen.toPositionString(0, chineseMove));

    move = 'd6e6';
    chineseMove = fen.toChineseString(move);
    logger.info(chineseMove);
    expect(chineseMove, '四兵平五');
    logger.info(fen.toPositionString(0, chineseMove));
  });
}
