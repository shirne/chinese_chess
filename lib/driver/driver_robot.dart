

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/chess_rule.dart';
import '../models/chess_item.dart';
import '../models/chess_fen.dart';
import '../models/engine.dart';
import '../models/player.dart';
import '../models/chess_pos.dart';

import 'player_driver.dart';

class DriverRobot extends PlayerDriver{
  DriverRobot(Player player) : super(player);
  Completer<String> requestMove;
  bool isCleared = true;

  Future<bool> tryDraw(){
    return Future.value(true);
  }

  @override
  Future<String> move() {
    requestMove = Completer<String>();

    // 网页版用不了引擎
    Future.delayed(Duration(seconds: 1)).then((value) {
      if(Engine.isSupportEngine) {
        getMoveFromEngine();
      }else {
        getMove();
      }
    });

    return requestMove.future;
  }
  getMoveFromEngine() async{
    player.manager.startEngine().then((v){
      if(v){
        player.manager.engine.requestMove(player.manager.fenStr, depth: 10)
            .then(onEngineMessage);
      }else{
        getMove();
      }
    });
  }

  onEngineMessage(String message){
    List<String> parts = message.split(' ');
    switch (parts[0]) {
      case 'ucciok':
        break;
      case 'nobestmove':
      case 'isbusy':
        if(!isCleared){
          isCleared=true;
          return;
        }
        if (!requestMove.isCompleted) {
          player.manager.engine.removeListener(onEngineMessage);
          getMove();
        }
        break;
      case 'bestmove':
        if(!isCleared){
          isCleared=true;
          return;
        }
        player.manager.engine.removeListener(onEngineMessage);
        completeMove(parts[1]);
        break;
      case 'info':
        break;
      case 'id':
      case 'option':
      default:
        return;
    }
  }

  getMove() async{
    print('thinking');
    int team = player.team == 'r'?0:1;
    List<String> moves = await getAbleMoves(player.manager.fen, team);
    if(moves.length < 1 ){
      completeMove('giveup');
      return;
    }
    //print(moves);
    await Future.delayed(Duration(milliseconds: 100));
    List<List<String>> moveGroups = await checkMoves(player.manager.fen, team, moves);
    //print(moveGroups);
    await Future.delayed(Duration(milliseconds: 100));

    String move = await pickMove(moveGroups);
    //print(move);
    completeMove(move);
  }


  /// 获取可以走的着法
  Future<List<String>> getAbleMoves(ChessFen fen, int team) async{
    List<String> moves = [];
    List<ChessItem> items = fen.getAll();
    items.forEach((item) {
      if(item.team == team) {
        List<String> curMoves =
            ChessRule(fen).movePoints(item.position).map<String>((toPos) => item
                .position.toCode() + toPos).toList();

        curMoves = curMoves.where((move) {
          ChessRule rule = ChessRule(fen.copy());
          rule.fen.move(move);
          if(rule.isKingMeet(team)){
            return false;
          }
          if(rule.isCheck(team)){
            return false;
          }
          return true;
        }).toList();
        if(curMoves.length > 0){
          moves += curMoves;
        }
      }
    });

    return moves;
  }

  /// todo 检查着法优势 吃子（被吃子是否有根以及与本子权重），躲吃，生根，将军，叫杀 将着法按权重分组
  Future<List<List<String>>> checkMoves(ChessFen fen, int team, List<String> moves) async{
    // 着法分类
    List<List<String>> groups = [
      [], // 0.将军
      [], // 1.叫杀
      [], // 2.挡将，挡杀
      [], // 3.捉
      [], // 4.保
      [], // 5.吃
      [], // 6.躲
      [], // 7.闲
    ];
    ChessRule rule = ChessRule(fen);

    int enemyTeam = team == 0 ? 1 : 0;
    // 被将军的局面，生成的都是挡着
    if(rule.isCheck(team)){
      // groups[2] = moves;
      List<String> canChecks = [];
      List<String> canotChecks = [];

      // todo 计算挡着深度
      moves.forEach((move) {
        ChessRule nRule = ChessRule(fen.copy());
        nRule.fen.move(move);

        // 走着后还能不能被将
        bool canCheck = nRule.teamCanCheck(enemyTeam);
        if(!canCheck){
          canChecks.add(move);
        }else{
          canotChecks.add(move);
        }
      });
      groups[2] = canotChecks + canChecks;
    }else {
      moves.forEach((move) {
        ChessPos fromPos = ChessPos.fromCode(move.substring(0, 2));
        ChessPos toPos = ChessPos.fromCode(move.substring(2, 4));

        String chess = fen[fromPos.y][fromPos.x];
        String toChess = fen[fromPos.y][fromPos.x];
        if (toChess != '0') {
          groups[5].add(move);
        }

        ChessRule mRule = ChessRule(fen.copy());
        mRule.fen.move(move);

        // 走招后要被将军
        if(rule.teamCanCheck(enemyTeam)){
          List<String> checkMoves = rule.getCheckMoves(enemyTeam);
          checkMoves.forEach((eMove) {
            ChessRule eRule = ChessRule(mRule.fen.copy());
            eRule.fen.move(eMove);
            // 不能应将，就是杀招
            if(eRule.canParryKill(team)){

            }else{

            }
          });
        }else{

        }
      });

      // 检查位置评分
      Map<String, int> posLevels = {};
      List<String> poses = moves.map<String>((move) => move.substring(2, 4))
          .toList();


      poses.forEach((pos) {
        if (posLevels.containsKey(pos)) return;
        ChessPos target = ChessPos.fromCode(pos);
        // 己方根数
        int selfRoots = rule.rootCount(target, team);

        // 对方根数
        int enemyRoots = rule.rootCount(target, team == 0 ? 1 : 0);

        // 己方无根，对方有根
        if(selfRoots < 1 && enemyRoots > 0){
          posLevels[pos] = -2;
        }else {
          posLevels[pos] = selfRoots - enemyRoots;
        }
      });

      // 生成每步招法的权重
      Map<String, int> posWeights = {};
      moves.forEach((move) {
        int weight = rule.positionWeight(
            ChessPos.fromCode(move.substring(0, 2)));
        ChessRule nextRule = ChessRule(rule.fen.copy());
        nextRule.fen.move(move);
        String toPos = move.substring(2, 4);
        int toWeight = rule.positionWeight(ChessPos.fromCode(toPos));
        int group = toWeight - weight + posLevels[toPos];
        posWeights[move] = group;
      });

      print(posWeights);
      moves.sort((item, item2) =>
      -posWeights[item].compareTo(posWeights[item2]));
    }

    return groups;
  }

  /// todo 从分组好的招法中随机筛选一个
  Future<String> pickMove(List<List<String>> groups) async{
    int groupIndex = 0;
    int index = 0;
    Random random = Random(DateTime
        .now()
        .millisecondsSinceEpoch);

    List<String> moves = groups[groupIndex];
    while (moves.length < 1 || random.nextDouble() > 0.4) {
      groupIndex++;
      if (groupIndex >= groups.length) {
        groupIndex = 0;
      }
      moves = groups[groupIndex];
    }

    while (random.nextDouble() > 0.4) {
      index ++;
      if (index >= moves.length) {
        index = 0;
      }
    }

    return moves[index];
  }

  @override
  Future<String> ponder() {
    // TODO: implement ponder
    throw UnimplementedError();
  }

  @override
  completeMove(String move) async{
    player.onMove(move).then((value){
      requestMove.complete(move);
    });
  }

  @override
  Future<bool> tryRetract() {
    // TODO: implement tryRetract
    throw UnimplementedError();
  }
}