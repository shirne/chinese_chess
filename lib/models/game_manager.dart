
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'chess_manual.dart';
import 'chess_map.dart';
import 'chess_rule.dart';
import 'chess_step.dart';
import 'engine.dart';
import 'hand.dart';

class GameManager{
  static const startFen = 'rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1';

  String skin = 'woods';

  // 当前对局
  ChessManual manual;
  
  // 算法引擎
  Engine engine;
  bool engineOK;

  // 选手
  List<Hand> hands = [];
  int curHand = 0;

  // 布局
  ChessMap map;

  // 着法历史
  List<ChessStep> steps = [];
  int unEatCount = 0;

  String currentFen;

  ValueNotifier<String> stepNotifier;
  ValueNotifier<String> messageNotifier;

  ValueNotifier<int> playerNotifier;

  // 走子规则
  ChessRule rule;

  GameManager(){
    rule = ChessRule();
    hands.add(Hand('r', title: '红方'));
    hands.add(Hand('b', title: '黑方'));
    curHand = 0;
    map = ChessMap.fromFen(startFen);
    stepNotifier = ValueNotifier<String>('==开始==');
    messageNotifier = ValueNotifier<String>('');
    playerNotifier = ValueNotifier(curHand);
    engine = Engine();
    engineOK = false;
    engine.init().then((process){
      engine.onMessage(parseMessage);
    });
  }

  parseMessage(String message){
    List<String> parts = message.split(' ');
    switch(parts[0]){

      case 'ucciok':
        engineOK = true;
        break;
      case 'nobestmove':
        break;
      case 'bestmove':
        break;
      case 'info':
        break;
      case 'id':
      case 'option':
      default:
        print(message);
    }
    messageNotifier.value = message;
  }

  loadPGN(String pgn){
    String content = '';
    if(!pgn.contains('\n')) {
      File file = File.fromUri(Uri(path:pgn));
      if (file != null) {
        content = file.readAsStringSync(encoding: Encoding.getByName('gbk'));
      }
    }else{
      content = pgn;
    }
    manual = ChessManual.load(content);
    if(manual.fen.isEmpty){
      map = ChessMap.fromFen(startFen);
    }else{
      map = ChessMap.fromFen(manual.fen);
    }
    stepNotifier.value = 'clear';
    messageNotifier.value = 'clear';

    // 加载步数
    if(manual.moves.length > 0){
      steps = manual.moves.map<ChessStep>((e) => ChessStep('', e)).toList();
      stepNotifier.value = steps.map<String>((e) => e.toString()).join('\n');
    }
  }

  loadFen(String fen){
    map.load(fen);
  }

  addStep(ChessItem chess, ChessItem next){
    steps.add(ChessStep(chess.code, chess.position+next.position, isEat: !next.isBlank));
    if(next.isBlank){
      unEatCount ++;
    }else{
      unEatCount = 0;
    }
    stepNotifier.value = steps.last.toString();
  }

  getSteps(){
    return steps.map<String>((cs){
      return cs.toString();
    }).toList();
  }

  destroy(){
    engine.stop();
    engine.quit();
    stepNotifier = null;
    messageNotifier = null;
  }

  switchPlayer(){
    curHand++;
    if(curHand >= hands.length){
      curHand = 0;
    }

    playerNotifier.value = curHand;
    print('切换选手:${player.team}');

    engine.stop();
    currentFen = map.toFen();
    engine.position(currentFen + ' ' + (curHand>0?'b':'w') + ' - - $unEatCount ' + (steps.length ~/ 2).toString());
    engine.go(depth: 10);
  }

  get player{
    return hands[curHand];
  }

}