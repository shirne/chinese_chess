
import 'dart:convert';
import 'dart:io';

import 'chess_manual.dart';
import 'chess_map.dart';
import 'chess_rule.dart';
import 'chess_step.dart';
import 'engine.dart';
import 'hand.dart';

class Gamer{
  String skin = 'woods';

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

  // 走子规则
  ChessRule rule;

  Gamer(){
    rule = ChessRule();
    hands.add(Hand('r'));
    hands.add(Hand('b'));
    curHand = 0;
    map = ChessMap.fromFen('rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1');
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
      case 'info':
        break;
      case 'id':
      case 'option':
      default:
        print(message);
    }
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
  }

  destroy(){
    engine.quit();
  }

  switchPlayer(){
    curHand++;
    if(curHand >= hands.length){
      curHand = 0;
    }
    print('切换选手:${player.team}');

    engine.position(map.toFen()+(curHand>0?'b':'w')+' - - $unEatCount '+(steps.length ~/ 2).toString());
    engine.go();
  }

  get player{
    return hands[curHand];
  }


}