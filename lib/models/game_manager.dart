
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

  String skin = 'woods';

  // 当前对局
  ChessManual manual;
  
  // 算法引擎
  Engine engine;
  bool engineOK;

  // 是否重新请求招法时的强制stop
  bool isStop = false;

  // 选手
  List<Hand> hands = [];
  int curHand = 0;

  // 布局
  ChessMap map;

  // 着法历史
  List<ChessStep> steps = [];

  int currentStep = 0;

  bool isCheckMate = false;

  // 未吃子着数(半回合数)
  int unEatCount = 0;

  // 回合数
  int round = 0;

  String currentFen;

  ValueNotifier<String> stepNotifier;
  ValueNotifier<String> messageNotifier;

  ValueNotifier<int> playerNotifier;
  ValueNotifier<int> gameNotifier;

  // 走子规则
  ChessRule rule;

  GameManager(){
    rule = ChessRule();
    hands.add(Hand('r', title: '红方'));
    hands.add(Hand('b', title: '黑方'));
    curHand = 0;
    map = ChessMap.fromFen(ChessManual.startFen);
    stepNotifier = ValueNotifier<String>('==开始==');
    messageNotifier = ValueNotifier<String>('');
    playerNotifier = ValueNotifier(curHand);
    gameNotifier = ValueNotifier(-1);

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
        messageNotifier.value = 'Engine is OK!';
        break;
      case 'nobestmove':
        // 强行stop后的nobestmove忽略
        if(isStop){
          isStop = false;
          return;
        }
        break;
      case 'bestmove':
        break;
      case 'info':
        break;
      case 'id':
      case 'option':
      default:
        return;
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
      map = ChessMap.fromFen(ChessManual.startFen);
    }else{
      map = ChessMap.fromFen(manual.fen);
    }

    // 加载步数
    if(manual.moves.length > 0){
      steps = manual.moves;
      stepNotifier.value = steps.map<String>((e) => e.toChineseString()).join('\n');
    }

    currentStep = 0;
    gameNotifier.value = 0;
    stepNotifier.value = 'clear';
    messageNotifier.value = 'clear';
  }

  loadFen(String fen){
    map.load(fen);
  }

  // 重载历史局面
  loadHistory(int index){
    if(index > steps.length){
      print('History error');
      return;
    }
    if(index == currentStep){
      return;
    }
    currentStep = index;
    loadFen(steps[currentStep].fen);

    gameNotifier.value = currentStep;
  }

  addStep(ChessItem chess, ChessItem next){
    // 如果当前不是最后一步，移除后面着法
    if(currentStep < steps.length - 1){
      steps.removeRange(currentStep + 1, steps.length - 1);
      gameNotifier.value = -1;
    }
    if(curHand == 0){
      round ++;
      steps.add(ChessStep(
          curHand,
          chess.code, chess.position + next.position, isEat: !next.isBlank,
          round: round,
          fen: map.toFen()));
    }else {
      steps.add(ChessStep(
          curHand,
          chess.code, chess.position + next.position, isEat: !next.isBlank,
          fen: map.toFen()));
    }
    currentStep = steps.length - 1;
    if(next.isBlank){
      unEatCount ++;
    }else{
      unEatCount = 0;
    }
    stepNotifier.value = steps.last.toChineseString();
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

    isCheckMate = rule.checkCheckMate(curHand, currentFen);

    messageNotifier.value = 'clear';
    isStop = true;
    engine.stop();
    currentFen = map.toFen();
    engine.position(currentFen + ' ' + (curHand>0?'b':'w') + ' - - $unEatCount ' + (steps.length ~/ 2).toString());
    engine.go(depth: 10);
  }

  get player{
    return hands[curHand];
  }

}