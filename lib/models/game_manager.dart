
import 'dart:io';

import 'package:chinese_chess/driver/player_driver.dart';
import 'package:chinese_chess/models/chess_skin.dart';
import 'package:flutter/material.dart';
import 'package:gbk2utf8/gbk2utf8.dart';

import 'chess_fen.dart';
import 'chess_manual.dart';
import 'chess_pos.dart';
import 'chess_rule.dart';
import 'engine.dart';
import 'player.dart';

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
  List<Player> hands = [];
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

  // 界面锁定通知
  ValueNotifier<bool> lockNotifier;

  // 走棋通知
  ValueNotifier<String> moveNotifier;

  // 走子规则
  ChessRule rule;

  GameManager(){
    manual = ChessManual();
    rule = ChessRule(manual.currentFen);

    hands.add(Player('r', this, title: manual.red));
    hands.add(Player('b', this, title: manual.black));
    curHand = 0;
    //map = ChessMap.fromFen(ChessManual.startFen);

    stepNotifier = ValueNotifier<String>('==开始==');
    messageNotifier = ValueNotifier<String>('');
    playerNotifier = ValueNotifier(curHand);
    gameNotifier = ValueNotifier(-1);
    resultNotifier = ValueNotifier('');
    lockNotifier = ValueNotifier(true);
    moveNotifier = ValueNotifier('');

    skin = ChessSkin("woods");
    skin.readyNotifier.addListener(() {
      gameNotifier.value = 0;
      next();
    });

    engine = Engine();
    engineOK = false;
    engine.init();
    engine.addListener(parseMessage);
  }

  bool get isLock{
    return lockNotifier.value;
  }
  bool get canBacktrace{
    return player.canBacktrace;
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

  void parseMessage(String message){
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
    gameNotifier.value = -1;
    isStop = true;
    engine.stop();
    currentStep = 0;
    stepNotifier.value = 'clear';
    messageNotifier.value = 'clear';
    resultNotifier.value = '';
    lockNotifier.value = true;

    manual = ChessManual(fen:fen);
    rule = ChessRule(manual.currentFen);
    hands[0].title = manual.red;
    hands[1].title = manual.black;
    curHand = manual.startHand;

    gameNotifier.value = 0;
    next();
  }

  loadPGN(String pgn){
    gameNotifier.value = -1;
    currentStep = 0;
    stepNotifier.value = 'clear';
    messageNotifier.value = 'clear';
    resultNotifier.value = '';
    lockNotifier.value = true;

    _loadPGN(pgn).then((result){
      gameNotifier.value = 0;
      next();
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
    hands[0].title = manual.red;
    hands[1].title = manual.black;
    // 加载步数
    if(manual.moves.length > 0){
      // print(manual.moves);
      stepNotifier.value = manual.moves.map<String>((e) => e.toChineseString()).join('\n');
    }
    manual.loadHistory(0);
    rule.fen = manual.currentFen;
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

  /// 切换驱动
  switchDriver(int team, DriverType driverType){
    hands[team].driverType = driverType;
    if(team == curHand && driverType == DriverType.robot){
      lockNotifier.value = true;
      next();
    }else if(driverType == DriverType.user){
      lockNotifier.value = false;
    }
  }

  /// 调用对应的玩家开始下一步
  next(){
    player.move().then((String move){
      addMove(move);
    });
  }

  /// 从用户落着 todo 检查出发点是否有子，检查落点是否对方子
  addStep(ChessPos from, ChessPos next){
    addMove('${from.toCode()}${next.toCode()}');
  }

  addMove(String move){
    print('addmove $move');
    if(PlayerDriver.isAction(move)){
      if(move == PlayerDriver.rstGiveUp){
        setResult(curHand == 0 ? ChessManual.resultFstLoose : ChessManual.resultFstWin, '认输');
      }
      if(move == PlayerDriver.rstDraw){
        setResult(ChessManual.resultFstDraw);
      }
      if(move == PlayerDriver.rstRetract){
        // todo 悔棋
      }
      if(move.contains(PlayerDriver.rstRqstDraw)) {
        move = move.replaceAll(PlayerDriver.rstRqstDraw,'').trim();
        if(move.isEmpty) {
          return;
        }
      }else{
        return;
      }
    }

    if(!ChessManual.isPosMove(move)){
      print('着法错误 $move');
      return;
    }

    if(fen.hasItemAt(ChessPos.fromCode(move.substring(2,4)))){
      unEatCount ++;
    }else{
      unEatCount = 0;
    }

    // 如果当前不是最后一步，移除后面着法
    if(currentStep < manual.moves.length){
      gameNotifier.value = -2;
      stepNotifier.value = 'clear';
      manual.addMove(move, addStep: currentStep);
    }else {
      gameNotifier.value = -2;
      manual.addMove(move);
    }

    currentStep = manual.moves.length;

    stepNotifier.value = manual.moves.last.toChineseString();

    checkResult(curHand == 0 ? 1 : 0, currentStep - 1);
  }

  setResult(String result, [String description = '']){
    if(ChessManual.results.contains(result)){
      print('结果不合法');
      return;
    }
    resultNotifier.value = '$result $description';
    manual.result = result;
  }

  /// 棋局结果判断
  checkResult(int hand, int curMove) async{
    // 判断和棋
    if(unEatCount >= 120){
      setResult(ChessManual.resultFstDraw, '60回合无吃子判和');
      return;
    }

    isCheckMate = rule.isCheckMate(hand);

    // 判断输赢，包括能否应将，长将
    if(isCheckMate){
      manual.moves[curMove].isCheckMate = isCheckMate;

      if(rule.canParryKill(hand)){
        // todo 改进算法
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
              setResult(hand == 0 ? ChessManual.resultFstLoose : ChessManual.resultFstWin, '不变招长将作负');
              return;
            }
            hisMove -= 2;
          }
        }

        resultNotifier.value = 'checkMate';
      }else{
        setResult(hand == 0 ? ChessManual.resultFstLoose : ChessManual.resultFstWin);
      }
    }else{
      if(rule.isTrapped(hand)){
        setResult(hand == 0 ? ChessManual.resultFstLoose : ChessManual.resultFstWin, '困毙');
      }
    }
  }

  getSteps(){
    return manual.moves.map<String>((cs){
      return cs.toString();
    }).toList();
  }

  dispose(){
    engine.stop();
    engine.quit();
  }

  switchPlayer(){
    curHand++;
    if(curHand >= hands.length){
      curHand = 0;
    }

    playerNotifier.value = curHand;
    print('切换选手:${player.title} ${player.team} ${player.driver}');

    resultNotifier.value = '';
    print(player.title);
    player.move().then((move){
      addMove(move);
    });

    messageNotifier.value = 'clear';
    isStop = true;
    engine.stop();
    //currentFen = map.toFen();
    engine.position(manual.currentFen.fen + ' ' + (curHand>0?'b':'w') + ' - - $unEatCount ' + (manual.moves.length ~/ 2).toString());
    engine.go(depth: 10);
  }

  String get fenStr{
    return '${manual.currentFen.fen} ${curHand>0?'b':'w'} - - 0 1';
  }

  Player get player{
    return hands[curHand];
  }

  Player getPlayer(int hand){
    return hands[hand];
  }

}