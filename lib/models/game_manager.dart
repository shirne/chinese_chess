
import 'dart:convert';
import 'dart:io';

import 'package:chinese_chess/models/chess_skin.dart';
import 'package:flutter/material.dart';
import 'package:gbk2utf8/gbk2utf8.dart';

import 'chess_fen.dart';
import 'chess_manual.dart';
import 'chess_pos.dart';
import 'chess_rule.dart';
import 'engine.dart';
import 'hand.dart';

class GameManager{

  ChessSkin skin;

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

  // 当前着法序号
  int currentStep = 0;

  // 是否将军
  bool isCheckMate = false;

  // 未吃子着数(半回合数)
  int unEatCount = 0;

  // 回合数
  int round = 0;

  // 走子事件
  ValueNotifier<String> stepNotifier;

  // 引擎消息事件
  ValueNotifier<String> messageNotifier;

  // 玩家事件
  ValueNotifier<int> playerNotifier;

  // 游戏加载事件
  ValueNotifier<int> gameNotifier;

  // 结果事件 包含将军
  ValueNotifier<String> resultNotifier;

  // 走子规则
  ChessRule rule;

  GameManager(){
    manual = ChessManual();
    rule = ChessRule(manual.currentFen);

    hands.add(Hand('r', title: '红方'));
    hands.add(Hand('b', title: '黑方'));
    curHand = 0;
    //map = ChessMap.fromFen(ChessManual.startFen);

    stepNotifier = ValueNotifier<String>('==开始==');
    messageNotifier = ValueNotifier<String>('');
    playerNotifier = ValueNotifier(curHand);
    gameNotifier = ValueNotifier(-1);
    resultNotifier = ValueNotifier('');

    skin = ChessSkin("woods");
    skin.readyNotifier.addListener(() {
      gameNotifier.value = 0;
    });

    engine = Engine();
    engineOK = false;
    engine.init().then((process){
      engine.onMessage(parseMessage);
    });
  }

  ChessFen get fen{
    return manual.currentFen;
  }

  String get lastMove{
    if(manual.moves.length < 1 || currentStep == 0){
      return '';
    }
    return manual.moves[currentStep - 1].move;
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

  newGame([String fen = ChessManual.startFen]){
    isStop = true;
    engine.stop();
    currentStep = 0;
    stepNotifier.value = 'clear';
    messageNotifier.value = 'clear';
    resultNotifier.value = '';

    manual = ChessManual(fen:fen);
    rule = ChessRule(manual.currentFen);
    curHand = manual.startHand;

    gameNotifier.value = 0;
  }

  loadPGN(String pgn){
    gameNotifier.value = -1;
    currentStep = 0;
    stepNotifier.value = 'clear';
    messageNotifier.value = 'clear';
    resultNotifier.value = '';

    _loadPGN(pgn).then((result){
      gameNotifier.value = 0;
    });
  }

  _loadPGN(String pgn) async{
    isStop = true;
    engine.stop();

    String content = '';
    if(!pgn.contains('\n')) {
      File file = File(pgn);
      if (file != null) {
        //content = file.readAsStringSync(encoding: Encoding.getByName('gbk'));
        content = gbk.decode(file.readAsBytesSync());
      }
    }else{
      content = pgn;
    }
    manual = ChessManual.load(content);

    // 加载步数
    if(manual.moves.length > 0){
      print(manual.moves);
      stepNotifier.value = manual.moves.map<String>((e) => e.toChineseString()).join('\n');
    }
    manual.loadHistory(0);
    stepNotifier.value = 'step';

    curHand = manual.startHand;
    return true;
  }

  loadFen(String fen){
    newGame(fen);
  }

  // 重载历史局面
  loadHistory(int index){
    if(index > manual.moves.length){
      print('History error');
      return;
    }
    if(index == currentStep){
      print('History no change');
      return;
    }
    currentStep = index;
    manual.loadHistory(index);
    rule.fen = manual.currentFen;
    curHand = currentStep % 2;

    gameNotifier.value = currentStep;
    print('history $currentStep');
  }

  /// 落着 todo 检查出发点是否有子，检查落点是否对方子
  addStep(ChessPos from, ChessPos next){
    if(fen.hasItemAt(next)){
      unEatCount ++;
    }else{
      unEatCount = 0;
    }

    // 如果当前不是最后一步，移除后面着法
    if(currentStep < manual.moves.length){
      gameNotifier.value = -2;
      stepNotifier.value = 'clear';
      manual.addMove(from.toCode() + next.toCode(), addStep: currentStep);
    }else {
      gameNotifier.value = -2;
      manual.addMove(from.toCode() + next.toCode());
    }

    currentStep = manual.moves.length;

    stepNotifier.value = manual.moves.last.toChineseString();

    checkResult(curHand == 0 ? 1 : 0, currentStep - 1);

  }

  checkResult(int hand, int curMove) async{
    // 判断和棋
    if(unEatCount >= 120){
      resultNotifier.value = '1/2-1/2 60回合无吃子判和';
    }

    isCheckMate = rule.isCheckMate(hand);

    // 判断输赢，包括能否应将，长将
    if(isCheckMate){
      manual.moves[curMove].isCheckMate = isCheckMate;

      if(rule.canParryKill(hand)){
        if(manual.moves.length > 6) {
          String cmMove = manual.moves[curMove].move;
          String parryMove = manual.moves[curMove - 1].move;
          int hisMove = curMove - 2;
          while(hisMove > 0){
            if(cmMove != manual.moves[hisMove].move ||
                parryMove != manual.moves[hisMove + 1].move){
              break;
            }
            if(hisMove + 6 < curMove){
              if(hand == 0) {
                resultNotifier.value = '0-1 不变招长将作负';
                manual.result = '0-1';
              }else{
                resultNotifier.value = '1-0 不变招长将作负';
                manual.result = '1-0';
              }
              break;
            }
            hisMove -= 2;
          }
        }

        resultNotifier.value = 'checkMate';
      }else{
        if(hand == 0) {
          resultNotifier.value = '0-1';
          manual.result = '0-1';
        }else{
          resultNotifier.value = '1-0';
          manual.result = '1-0';
        }
      }
    }
  }

  getSteps(){
    return manual.moves.map<String>((cs){
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

    resultNotifier.value = '';

    messageNotifier.value = 'clear';
    isStop = true;
    engine.stop();
    //currentFen = map.toFen();
    engine.position(manual.currentFen.fen + ' ' + (curHand>0?'b':'w') + ' - - $unEatCount ' + (manual.moves.length ~/ 2).toString());
    engine.go(depth: 10);
  }

  get player{
    return hands[curHand];
  }

}