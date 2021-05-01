

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/engine.dart';
import '../models/chess_rule.dart';
import '../models/chess_item.dart';
import '../models/chess_fen.dart';
import '../models/player.dart';

import 'player_driver.dart';

class DriverRobot extends PlayerDriver{
  DriverRobot(Player player) : super(player);
  Completer<String> requestMove;
  Engine engine;

  Future<bool> tryDraw(){
    return Future.value(true);
  }

  @override
  Future<String> move() {
    requestMove = Completer<String>();

    // 网页版用不了引擎
    Future.delayed(Duration(seconds: 1)).then((value) {
      if(kIsWeb) {
        getMove();
      }else {
        getMoveFromEngine();
      }
    });

    return requestMove.future;
  }
  getMoveFromEngine() async{
    if(engine == null) {
      engine = Engine();
      engine.addListener((String message) {
        List<String> parts = message.split(' ');
        switch (parts[0]) {
          case 'ucciok':
            break;
          case 'nobestmove':
            if (!requestMove.isCompleted) {
              getMove();
            }
            break;
          case 'bestmove':
            engine.quit();
            completeMove(parts[1]);
            break;
          case 'info':
            break;
          case 'id':
          case 'option':
          default:
            return;
        }
      });
    }
    engine.init().then((value) {
      engine.position(player.manager.fenStr);
      engine.go(depth: 10);
    });

  }

  getMove() async{
    print('thinking');
    List<String> moves = await getAlbeMoves(player.manager.fen, player.team == 'r'?0:1);
    if(moves.length < 1 ){
      return 'giveup';
    }
    await Future.delayed(Duration(milliseconds: 100));
    List<List<String>> moveGroups = await checkMoves(player.manager.fen, player.team == 'r'?0:1, moves);

    await Future.delayed(Duration(milliseconds: 100));

    String move = await pickMove(moveGroups);

    completeMove(move);
  }


  /// 获取可以走的着法
  Future<List<String>> getAlbeMoves(ChessFen fen, int team) async{
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
          if(rule.isCheckMate(team)){
            return false;
          }
          return true;
        }).toList();
      }
    });

    return moves;
  }

  /// todo 检查着法优势 吃子（被吃子是否有根以及与本子权重），躲吃，生根，将军，叫杀 将着法按权重分组
  Future<List<List<String>>> checkMoves(ChessFen fen, int team, List<String> moves) async{


    return [moves];
  }

  /// todo 从分组好的招法中随机筛选一个
  Future<String> pickMove(List<List<String>> moveGroups) async{

    moveGroups[0].shuffle();
    return moveGroups[0][0];
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