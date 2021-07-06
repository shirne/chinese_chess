import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/engine_type.dart';
import '../xqlite/util.dart';
import '../xqlite/position.dart';
import '../xqlite/search.dart';
import '../models/chess_rule.dart';
import '../models/chess_item.dart';
import '../models/chess_fen.dart';
import '../models/engine.dart';
import '../models/player.dart';
import '../models/chess_pos.dart';

import 'player_driver.dart';

class DriverRobot extends PlayerDriver {
  DriverRobot(Player player) : super(player);
  Completer<String> requestMove;
  bool isCleared = true;

  Position position;
  Search search;

  Future<bool> tryDraw() {
    return Future.value(true);
  }

  @override
  Future<String> move() {
    requestMove = Completer<String>();

    // 网页版用不了引擎
    Future.delayed(Duration(seconds: 1)).then((value) {
      if (Engine.isSupportEngine &&
          player.manager.setting.robotType == EngineType.elephantEye) {
        getMoveFromEngine();
      } else {
        // getMove();
        getBuiltInMove();
      }
    });

    return requestMove.future;
  }

  getMoveFromEngine() async {
    player.manager.startEngine().then((v) {
      if (v) {
        player.manager.engine
            .requestMove(player.manager.fenStr, depth: 10)
            .then(onEngineMessage);
      } else {
        getMove();
      }
    });
  }

  onEngineMessage(String message) {
    List<String> parts = message.split(' ');
    switch (parts[0]) {
      case 'ucciok':
        break;
      case 'nobestmove':
      case 'isbusy':
        if (!isCleared) {
          isCleared = true;
          return;
        }
        if (!requestMove.isCompleted) {
          player.manager.engine.removeListener(onEngineMessage);
          getMove();
        }
        break;
      case 'bestmove':
        if (!isCleared) {
          isCleared = true;
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

  getBuiltInMove() async {
    await XQIsoSearch.init();
    if (kIsWeb) {
      completeMove(
          await XQIsoSearch.getMove(IsoMessage(player.manager.fenStr, null)));
    } else {
      if (IsoMessage.bookData == null) {
        IsoMessage.bookData = await rootBundle.load('assets/engines/BOOK.DAT');
      }
      ReceivePort rPort = ReceivePort();
      rPort.listen((message) {
        completeMove(message);
      });
      Isolate.spawn<IsoMessage>(
        XQIsoSearch.getMove,
        IsoMessage(player.manager.fenStr, rPort.sendPort),
      );
    }
  }

  getMove() async {
    print('thinking');
    int team = player.team == 'r' ? 0 : 1;
    List<String> moves = await getAbleMoves(player.manager.fen, team);
    if (moves.length < 1) {
      completeMove('giveup');
      return;
    }
    //print(moves);
    await Future.delayed(Duration(milliseconds: 100));
    Map<String, int> moveGroups =
        await checkMoves(player.manager.fen, team, moves);
    //print(moveGroups);
    await Future.delayed(Duration(milliseconds: 100));

    String move = await pickMove(moveGroups);
    //print(move);
    completeMove(move);
  }

  /// 获取可以走的着法
  Future<List<String>> getAbleMoves(ChessFen fen, int team) async {
    List<String> moves = [];
    List<ChessItem> items = fen.getAll();
    items.forEach((item) {
      if (item.team == team) {
        List<String> curMoves = ChessRule(fen)
            .movePoints(item.position)
            .map<String>((toPos) => item.position.toCode() + toPos)
            .toList();

        curMoves = curMoves.where((move) {
          ChessRule rule = ChessRule(fen.copy());
          rule.fen.move(move);
          if (rule.isKingMeet(team)) {
            return false;
          }
          if (rule.isCheck(team)) {
            return false;
          }
          return true;
        }).toList();
        if (curMoves.length > 0) {
          moves += curMoves;
        }
      }
    });

    return moves;
  }

  /// todo 检查着法优势 吃子（被吃子是否有根以及与本子权重），躲吃，生根，将军，叫杀 将着法按权重分组
  Future<Map<String, int>> checkMoves(
      ChessFen fen, int team, List<String> moves) async {
    // 着法加分
    List<int> weights = [
      49, // 0.将军
      199, // 1.叫杀
      199, // 2.挡将，挡杀
      9, // 3.捉 这四项根据子力价值倍乘
      19, // 4.保
      19, // 5.吃
      9, // 6.躲
      0, // 7.闲 进 退
    ];
    Map<String, int> moveWeight = {};

    ChessRule rule = ChessRule(fen);

    int enemyTeam = team == 0 ? 1 : 0;
    // 被将军的局面，生成的都是挡着
    if (rule.isCheck(team)) {
      // 计算挡着后果
      moves.forEach((move) {
        ChessRule nRule = ChessRule(fen.copy());
        nRule.fen.move(move);

        // 走着后还能不能被将
        bool canCheck = nRule.teamCanCheck(enemyTeam);
        if (!canCheck) {
          moveWeight[move] = weights[2];
        } else {
          moveWeight[move] = weights[2] * 3;
        }
      });
    } else {
      // 获取要被吃的子
      List<ChessItem> willBeEaten = rule.getBeEatenList(team);

      moves.forEach((move) {
        moveWeight[move] = 0;
        ChessPos fromPos = ChessPos.fromCode(move.substring(0, 2));
        ChessPos toPos = ChessPos.fromCode(move.substring(2, 4));

        String chess = fen[fromPos.y][fromPos.x];
        String toChess = fen[toPos.y][toPos.x];
        if (toChess != '0') {
          int toRootCount = rule.rootCount(toPos, enemyTeam);
          int wPower = rule.getChessWeight(toPos);

          // 被吃子有根，则要判断双方子力价值才吃
          if (toRootCount > 0) {
            wPower -= rule.getChessWeight(fromPos);
          }
          moveWeight[move] += weights[5] * wPower;
        }
        int rootCount = rule.rootCount(fromPos, team);
        int eRootCount = rule.rootCount(fromPos, enemyTeam);

        // 躲吃
        /*if(rootCount < 1 && eRootCount > 0){
          moveWeight[move] += weights[6] * rule.getChessWeight(fromPos);
        }else if(rootCount < eRootCount){
          moveWeight[move] += weights[6] * (rule.getChessWeight(fromPos) - rule.getChessWeight(toPos));
        }*/

        // 开局兵不挡马路不动兵
        int chessCount = rule.fen.getAllChr().length;
        if (chessCount > 28) {
          if (chess == 'p') {
            if (fen[fromPos.y + 1][fromPos.x] == 'n') {
              moveWeight[move] += 9;
            }
          } else if (chess == 'P') {
            if (fen[fromPos.y - 1][fromPos.x] == 'N') {
              moveWeight[move] += 9;
            }
          }

          // 开局先动马炮
          if (['c', 'C', 'n', 'N'].contains(chess)) {
            moveWeight[move] += 9;
          }
        }
        if (chessCount > 20) {
          // 车马炮在原位的优先动
          if ((chess == 'C' &&
                  fromPos.y == 2 &&
                  (fromPos.x == 1 || fromPos.x == 7)) ||
              (chess == 'c' &&
                  fromPos.y == 7 &&
                  (fromPos.x == 1 || fromPos.x == 7))) {
            moveWeight[move] += 19;
          }
          if ((chess == 'N' && fromPos.y == 0) ||
              (chess == 'n' && fromPos.y == 9)) {
            moveWeight[move] += 19;
          }
          if ((chess == 'R' && fromPos.y == 0) ||
              (chess == 'r' && fromPos.y == 9)) {
            moveWeight[move] += 9;
          }
        }

        // 马往前跳权重增加
        if ((chess == 'n' && toPos.y < fromPos.y) ||
            (chess == 'N' && toPos.y > fromPos.y)) {
          moveWeight[move] += 9;
        }

        // 马在原位不动车
        if ((chess == 'r' && fromPos.y == 9) ||
            (chess == 'R' && fromPos.y == 0)) {
          ChessPos nPos = rule.fen.find(chess == 'R' ? 'N' : 'n');
          if (fromPos.x == 0) {
            if (nPos.x == 1 && nPos.y == fromPos.y) {
              moveWeight[move] -= rule.getChessWeight(nPos);
            }
          } else if (fromPos.x == 8) {
            if (nPos.x == 7 && nPos.y == fromPos.y) {
              moveWeight[move] -= rule.getChessWeight(nPos);
            }
          }
        }

        ChessPos ekPos = fen.find(enemyTeam == 0 ? 'K' : 'k');
        // 炮是否应着老将
        if (chess == 'c' || chess == 'C') {
          if (fromPos.y == ekPos.y || fromPos.x == ekPos.x) {
            if (toPos.y != ekPos.y && toPos.x != ekPos.x) {
              moveWeight[move] -= weights[0];
            }
          } else {
            if (toPos.y == ekPos.y || toPos.x == ekPos.x) {
              moveWeight[move] += weights[0];
            }
          }
        }

        ChessRule mRule = ChessRule(fen.copy());
        mRule.fen.move(move);

        // 走招后要被将军
        if (mRule.teamCanCheck(enemyTeam)) {
          List<String> checkMoves = mRule.getCheckMoves(enemyTeam);
          //print('将军招法: $checkMoves');
          checkMoves.forEach((eMove) {
            ChessRule eRule = ChessRule(mRule.fen.copy());
            eRule.fen.move(eMove);
            // 不能应将，就是杀招
            if (eRule.canParryKill(team)) {
              //print('$move 要被将军');
              moveWeight[move] -= weights[0];
            } else {
              print('$move 有杀招');
              moveWeight[move] -= weights[1];
            }
          });
        } else {
          rootCount = mRule.rootCount(toPos, team);
          eRootCount = mRule.rootCount(toPos, enemyTeam);

          willBeEaten.forEach((bItem) {
            // 当前走的子就是被吃的子
            if (bItem.position == fromPos) {
              // 走之后不被吃了
              if (eRootCount < 1) {
                moveWeight[move] += mRule.getChessWeight(toPos) * weights[6];
              } else if (rootCount > 0) {
                List<ChessItem> eItems = mRule.getBeEatList(toPos);
                moveWeight[move] += (mRule.getChessWeight(eItems[0].position) -
                        mRule.getChessWeight(toPos)) *
                    weights[6];
              }
            } else {
              // 不是被吃的子，但是也躲过去了
              int oRootCount = mRule.rootCount(bItem.position, enemyTeam);
              if (oRootCount < 1) {
                moveWeight[move] +=
                    mRule.getChessWeight(bItem.position) * weights[6];
              } else {
                // 有根了
                List<ChessItem> eItems = mRule.getBeEatList(bItem.position);
                moveWeight[move] += (mRule.getChessWeight(eItems[0].position) -
                        mRule.getChessWeight(bItem.position)) *
                    weights[6];
              }
            }
          });

          // 走着后要被吃
          if ((rootCount == 0 && eRootCount > 0) || rootCount < eRootCount) {
            moveWeight[move] -= mRule.getChessWeight(toPos) * weights[5];
          }

          // 捉子优先
          List<ChessItem> canEatItems = mRule.getEatList(toPos);
          List<ChessItem> oldCanEatItems = rule.getEatList(fromPos);
          int eatWeight = 0;
          oldCanEatItems.forEach((oItem) {
            eatWeight += mRule.getChessWeight(oItem.position) * weights[3];
          });
          canEatItems.forEach((oItem) {
            eatWeight -= mRule.getChessWeight(oItem.position) * weights[3];
          });
          moveWeight[move] -= eatWeight;
        }
      });
    }
    int minWeight = 0;
    moveWeight.forEach((key, value) {
      if (minWeight > value) minWeight = value;
    });

    if (minWeight < 0) {
      moveWeight.updateAll((key, value) => value - minWeight);
    }

    print(moveWeight);

    return moveWeight;
  }

  /// todo 从分组好的招法中随机筛选一个
  Future<String> pickMove(Map<String, int> groups) async {
    int totalSum = 0;
    groups.values.forEach((wgt) {
      wgt += 1;
      if (wgt < 0) wgt = 0;
      totalSum += wgt;
    });

    Random random = Random(DateTime.now().millisecondsSinceEpoch);

    double rand = random.nextDouble() * totalSum;
    int curSum = 0;
    String move = '';
    for (String key in groups.keys) {
      move = key;
      curSum += groups[key];
      if (curSum > rand) {
        break;
      }
    }

    return move;
  }

  @override
  Future<String> ponder() {
    // TODO: implement ponder
    throw UnimplementedError();
  }

  @override
  completeMove(String move) async {
    player.onMove(move).then((value) {
      requestMove.complete(move);
    });
  }

  @override
  Future<bool> tryRetract() {
    // TODO: implement tryRetract
    throw UnimplementedError();
  }
}
