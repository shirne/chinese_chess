import 'dart:async';
import 'dart:io';

import 'package:fast_gbk/fast_gbk.dart';
import 'package:flutter/material.dart';

import '../driver/player_driver.dart';
import '../global.dart';
import 'chess_skin.dart';
import 'game_setting.dart';
import 'sound.dart';
import 'chess_fen.dart';
import 'chess_manual.dart';
import 'chess_pos.dart';
import 'chess_rule.dart';
import 'engine.dart';
import 'player.dart';

class GameManager {
  late ChessSkin skin;
  double scale = 1;

  // 当前对局
  late ChessManual manual;

  // 算法引擎
  Engine? engine;
  bool engineOK = false;

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
  late ValueNotifier<String> stepNotifier;

  // 引擎消息事件
  late ValueNotifier<String> messageNotifier;

  // 玩家事件
  late ValueNotifier<int> playerNotifier;

  // 游戏加载事件
  late ValueNotifier<int> gameNotifier;

  // 结果事件 包含将军
  late ValueNotifier<String> resultNotifier;

  // 界面锁定通知
  late ValueNotifier<bool> lockNotifier;

  // 走棋通知
  late ValueNotifier<String> moveNotifier;

  // 走子规则
  late ChessRule rule;

  late GameSetting setting;

  GameManager();

  Future<bool> init() async {
    setting = await GameSetting.getInstance();
    manual = ChessManual();
    rule = ChessRule(manual.currentFen);

    hands.add(Player('r', this, title: manual.red));
    hands.add(Player('b', this, title: manual.black));
    curHand = 0;
    // map = ChessMap.fromFen(ChessManual.startFen);

    stepNotifier = ValueNotifier<String>('');
    messageNotifier = ValueNotifier<String>('');
    playerNotifier = ValueNotifier(curHand);
    gameNotifier = ValueNotifier(-1);
    resultNotifier = ValueNotifier('');
    lockNotifier = ValueNotifier(true);
    moveNotifier = ValueNotifier('');

    skin = ChessSkin("woods", this);
    skin.readyNotifier.addListener(() {
      gameNotifier.value = 0;
    });

    return true;
  }

  bool get isLock {
    return lockNotifier.value;
  }

  bool get canBacktrace {
    return player.canBacktrace;
  }

  ChessFen get fen {
    return manual.currentFen;
  }

  String get lastMove {
    if (manual.moves.isEmpty || currentStep == 0) {
      return '';
    }
    return manual.moves[currentStep - 1].move;
  }

  void parseMessage(String message) {
    List<String> parts = message.split(' ');
    String instruct = parts.removeAt(0);
    switch (instruct) {
      case 'ucciok':
        engineOK = true;
        messageNotifier.value = 'Engine is OK!';
        break;
      case 'nobestmove':
        // 强行stop后的nobestmove忽略
        if (isStop) {
          isStop = false;
          return;
        }
        break;
      case 'bestmove':
        logger.info(message);
        message = parseBaseMove(parts);
        break;
      case 'info':
        logger.info(message);
        message = parseInfo(parts);
        break;
      case 'id':
      case 'option':
      default:
        return;
    }
    messageNotifier.value = message;
  }

  String parseBaseMove(List<String> infos) {
    return "推荐着法: ${fen.toChineseString(infos[0])}"
        "${infos.length > 2 ? ' 猜测对方: ${fen.toChineseString(infos[2])}' : ''}";
  }

  String parseInfo(List<String> infos) {
    String first = infos.removeAt(0);
    switch (first) {
      case 'depth':
        String msg = infos[0];
        if (infos.isNotEmpty) {
          String sub = infos.removeAt(0);
          while (sub.isNotEmpty) {
            if (sub == 'score') {
              String score = infos.removeAt(0);
              msg += '(${score.contains('-') ? '' : '+'}$score)';
            } else if (sub == 'pv') {
              msg += fen.toChineseTree(infos).join(' ');
              break;
            }
            if (infos.isEmpty) break;
            sub = infos.removeAt(0);
          }
        }
        return msg;
      case 'time':
        return '耗时：${infos[0]}(ms)${infos.length > 2 ? ' 节点数 ${infos[2]}' : ''}';
      case 'currmove':
        return '当前招法: ${fen.toChineseString(infos[0])}${infos.length > 2 ? ' ${infos[2]}' : ''}';
      case 'message':
      default:
        return infos.join(' ');
    }
  }

  stop() {
    gameNotifier.value = -1;
    isStop = true;
    engine?.stop();
    currentStep = 0;
    stepNotifier.value = '';
    messageNotifier.value = '';
    resultNotifier.value = '';
    lockNotifier.value = true;
  }

  newGame([String fen = ChessManual.startFen]) {
    stop();

    stepNotifier.value = 'clear';
    messageNotifier.value = 'clear';
    manual = ChessManual(fen: fen);
    rule = ChessRule(manual.currentFen);
    hands[0].title = manual.red;
    hands[0].driverType = DriverType.user;
    hands[1].title = manual.black;
    hands[1].driverType = DriverType.user;
    curHand = manual.startHand;

    gameNotifier.value = 0;
    next();
  }

  loadPGN(String pgn) {
    stop();

    _loadPGN(pgn);
    gameNotifier.value = 0;
    next();
  }

  _loadPGN(String pgn) {
    isStop = true;
    engine?.stop();

    String content = '';
    if (!pgn.contains('\n')) {
      File file = File(pgn);
      if (file.existsSync()) {
        //content = file.readAsStringSync(encoding: Encoding.getByName('gbk'));
        content = gbk.decode(file.readAsBytesSync());
      }
    } else {
      content = pgn;
    }
    manual = ChessManual.load(content);
    hands[0].title = manual.red;
    hands[1].title = manual.black;
    // 加载步数
    if (manual.moves.isNotEmpty) {
      // print(manual.moves);
      stepNotifier.value =
          manual.moves.map<String>((e) => e.toChineseString()).join('\n');
    }
    manual.loadHistory(0);
    rule.fen = manual.currentFen;
    stepNotifier.value = 'step';

    curHand = manual.startHand;
    return true;
  }

  loadFen(String fen) {
    newGame(fen);
  }

  // 重载历史局面
  loadHistory(int index) {
    if (index > manual.moves.length) {
      logger.info('History error');
      return;
    }
    if (index == currentStep) {
      logger.info('History no change');
      return;
    }
    currentStep = index;
    manual.loadHistory(index);
    rule.fen = manual.currentFen;
    curHand = currentStep % 2;
    playerNotifier.value = curHand;

    gameNotifier.value = currentStep;
    logger.info('history $currentStep');
  }

  /// 切换驱动
  switchDriver(int team, DriverType driverType) {
    hands[team].driverType = driverType;
    if (team == curHand && driverType == DriverType.robot) {
      lockNotifier.value = true;
      next();
    } else if (driverType == DriverType.user) {
      lockNotifier.value = false;
    }
  }

  /// 调用对应的玩家开始下一步
  next() {
    player.move().then((String move) {
      addMove(move);
      checkResult(curHand == 0 ? 1 : 0, currentStep - 1).then((canNext) {
        logger.info(canNext);
        if (canNext) {
          switchPlayer();
        }
      });
    });
  }

  /// 从用户落着 todo 检查出发点是否有子，检查落点是否对方子
  addStep(ChessPos from, ChessPos next) async {
    player.completeMove('${from.toCode()}${next.toCode()}');
  }

  addMove(String move) {
    logger.info('addmove $move');
    if (PlayerDriver.isAction(move)) {
      if (move == PlayerDriver.rstGiveUp) {
        setResult(
            curHand == 0
                ? ChessManual.resultFstLoose
                : ChessManual.resultFstWin,
            '${player.title}认输');
      }
      if (move == PlayerDriver.rstDraw) {
        setResult(ChessManual.resultFstDraw);
      }
      if (move == PlayerDriver.rstRetract) {
        // todo 悔棋
      }
      if (move.contains(PlayerDriver.rstRqstDraw)) {
        move = move.replaceAll(PlayerDriver.rstRqstDraw, '').trim();
        if (move.isEmpty) {
          return;
        }
      } else {
        return;
      }
    }

    if (!ChessManual.isPosMove(move)) {
      logger.info('着法错误 $move');
      return;
    }

    if (fen.hasItemAt(ChessPos.fromCode(move.substring(2, 4)))) {
      unEatCount = 0;
      Sound.play(Sound.capture);
    } else {
      unEatCount++;
      Sound.play(Sound.move);
    }

    // 如果当前不是最后一步，移除后面着法
    if (currentStep < manual.moves.length) {
      gameNotifier.value = -2;
      stepNotifier.value = 'clear';
      manual.addMove(move, addStep: currentStep);
    } else {
      gameNotifier.value = -2;
      manual.addMove(move);
    }

    currentStep = manual.moves.length;

    stepNotifier.value = manual.moves.last.toChineseString();
  }

  setResult(String result, [String description = '']) {
    if (!ChessManual.results.contains(result)) {
      logger.info('结果不合法 $result');
      return;
    }
    logger.info('本局结果：$result');
    resultNotifier.value = '$result $description';
    if (result == ChessManual.resultFstDraw) {
      Sound.play(Sound.draw);
    } else if (result == ChessManual.resultFstWin) {
      Sound.play(Sound.win);
    } else if (result == ChessManual.resultFstLoose) {
      Sound.play(Sound.loose);
    }
    manual.result = result;
  }

  /// 棋局结果判断
  Future<bool> checkResult(int hand, int curMove) async {
    logger.info('checkResult');

    int repeatRound = manual.repeatRound();
    if (repeatRound > 2) {
      // 提醒
    }

    // 判断和棋
    if (unEatCount >= 120) {
      setResult(ChessManual.resultFstDraw, '60回合无吃子判和');
      return false;
    }

    isCheckMate = rule.isCheck(hand);
    logger.info('是否将军 $isCheckMate');

    // 判断输赢，包括能否应将，长将
    if (isCheckMate) {
      manual.moves[curMove].isCheckMate = isCheckMate;

      if (rule.canParryKill(hand)) {
        // 长将
        if (repeatRound > 3) {
          setResult(
              hand == 0 ? ChessManual.resultFstLoose : ChessManual.resultFstWin,
              '不变招长将作负');
          return false;
        }
        Sound.play(Sound.check);
        resultNotifier.value = 'checkMate';
        Future.delayed(const Duration(milliseconds: 30))
            .then((value) => resultNotifier.value = '');
      } else {
        setResult(
            hand == 0 ? ChessManual.resultFstLoose : ChessManual.resultFstWin,
            '绝杀');
        return false;
      }
    } else {
      if (rule.isTrapped(hand)) {
        setResult(
            hand == 0 ? ChessManual.resultFstLoose : ChessManual.resultFstWin,
            '困毙');
        return false;
      }
    }

    // todo 判断长捉，一捉一将，一将一杀
    if (repeatRound > 3) {
      setResult(ChessManual.resultFstDraw, '不变招判和');
      return false;
    }
    return true;
  }

  getSteps() {
    return manual.moves.map<String>((cs) {
      return cs.toString();
    }).toList();
  }

  dispose() {
    if (engine != null) {
      engine?.stop();
      engine?.quit();
      engine = null;
    }
  }

  switchPlayer() {
    curHand++;
    if (curHand >= hands.length) {
      curHand = 0;
    }

    playerNotifier.value = curHand;
    logger.info('切换选手:${player.title} ${player.team} ${player.driver}');

    resultNotifier.value = '';
    logger.info(player.title);
    next();

    messageNotifier.value = 'clear';
  }

  Future<bool> startEngine() {
    if (engine != null) {
      return Future.value(true);
    }
    Completer<bool> engineFuture = Completer<bool>();
    engine = Engine();
    engineOK = false;
    engine?.init().then((Process? v) {
      engineOK = true;
      engine?.addListener(parseMessage);
      engineFuture.complete(true);
    });
    return engineFuture.future;
  }

  requestHelp() {
    if (engine == null) {
      startEngine().then((v) {
        if (v) {
          requestHelp();
        } else {
          logger.info('engine is not support');
        }
      });
    } else {
      if (engineOK) {
        isStop = true;
        engine?.stop();
        engine?.position(fenStr);
        engine?.go(depth: 10);
      } else {
        logger.info('engine is not ok');
      }
    }
  }

  String get fenStr {
    return '${manual.currentFen.fen} ${curHand > 0 ? 'b' : 'w'}'
        ' - - $unEatCount ${manual.moves.length ~/ 2}';
  }

  Player get player {
    return hands[curHand];
  }

  Player getPlayer(int hand) {
    return hands[hand];
  }
}
