import 'dart:async';
import 'dart:io';

import 'package:cchess/cchess.dart';
import 'package:engine/engine.dart';
import 'package:fast_gbk/fast_gbk.dart';

import '../driver/player_driver.dart';
import '../global.dart';
import 'chess_skin.dart';
import 'game_event.dart';
import 'game_setting.dart';
import 'sound.dart';
import 'player.dart';

class GameManager {
  late ChessSkin skin;
  double scale = 1;

  // 当前对局
  late ChessManual manual;

  // 算法引擎
  Engine engine = Engine();
  StreamSubscription<EngineMessage>? listener;
  bool engineOK = false;

  // 是否重新请求招法时的强制stop
  bool isStop = false;

  // 是否翻转棋盘
  bool _isFlip = false;
  bool get isFlip => _isFlip;

  void flip() {
    add(GameFlipEvent(!isFlip));
  }

  // 是否锁定(非玩家操作的时候锁定界面)
  bool _isLock = false;
  bool get isLock => _isLock;

  // 选手
  List<Player> hands = [];
  int curHand = 0;

  // 当前着法序号
  int _currentStep = 0;
  int get currentStep => _currentStep;

  int get stepCount => manual.moveCount;

  // 是否将军
  bool get isCheckMate => manual.currentMove?.isCheckMate ?? false;

  // 未吃子着数(半回合数)
  int unEatCount = 0;

  // 回合数
  int round = 0;

  final gameEvent = StreamController<GameEvent>();
  final Map<GameEventType, List<void Function(GameEvent)>> listeners = {};

  // 走子规则
  late ChessRule rule;

  late GameSetting setting;

  static GameManager? _instance;

  static GameManager get instance => _instance ??= GameManager();

  GameManager._() {
    gameEvent.stream.listen(_onGameEvent);
  }

  factory GameManager() {
    _instance ??= GameManager._();
    return _instance!;
  }

  Future<bool> init() async {
    setting = await GameSetting.getInstance();
    manual = ChessManual();
    rule = ChessRule(manual.currentFen);

    hands.add(Player('r', this, title: manual.red));
    hands.add(Player('b', this, title: manual.black));
    curHand = 0;
    // map = ChessMap.fromFen(ChessManual.startFen);

    skin = ChessSkin("woods", this);
    skin.readyNotifier.addListener(() {
      add(GameLoadEvent(0));
    });

    listener = engine.listen(parseMessage);

    return true;
  }

  void on<T extends GameEvent>(void Function(GameEvent) listener) {
    final type = GameEvent.eventType(T);
    if (type == null) {
      logger.warning('type not match ${T.runtimeType}');
      return;
    }
    if (!listeners.containsKey(type)) {
      listeners[type] = [];
    }
    listeners[type]!.add(listener);
  }

  void off<T extends GameEvent>(void Function(GameEvent) listener) {
    final type = GameEvent.eventType(T);
    if (type == null) {
      logger.warning('type not match ${T.runtimeType}');
      return;
    }
    listeners[type]?.remove(listener);
  }

  void add<T extends GameEvent>(T event) {
    gameEvent.add(event);
  }

  void clear() {
    listeners.clear();
  }

  void _onGameEvent(GameEvent e) {
    if (e.type == GameEventType.lock) {
      _isLock = e.data;
    }
    if (e.type == GameEventType.flip) {
      _isFlip = e.data;
    }
    if (listeners.containsKey(e.type)) {
      for (var func in listeners[e.type]!) {
        func.call(e);
      }
    }
  }

  bool get canBacktrace => player.canBacktrace;

  ChessFen get fen => manual.currentFen;

  /// not last but current
  String get lastMove => manual.currentMove?.move ?? '';

  void parseMessage(EngineMessage message) {
    String tMessage = message.message;
    switch (message.type) {
      case MessageType.uciok:
      case MessageType.readyok:
        engineOK = true;
        add(GameEngineEvent('Engine is OK!'));
        break;
      case MessageType.nobestmove:
        // 强行stop后的nobestmove忽略
        if (isStop) {
          isStop = false;
          return;
        }
        break;
      case MessageType.bestmove:
        tMessage = parseBaseMove(tMessage.trim().split(' '));
        break;
      case MessageType.info:
        tMessage = parseInfo(tMessage.trim().split(' '));
        break;
      case MessageType.id:
      case MessageType.option:
      default:
        return;
    }
    add(GameEngineEvent(tMessage));
  }

  String parseBaseMove(List<String> infos) {
    if (infos.isEmpty) {
      return '';
    }
    return "推荐着法: ${fen.toChineseString(infos[0])}"
        "${infos.length > 2 ? ' 对方应招: ${fen.toChineseString(infos[2])}' : ''}";
  }

  String parseInfo(List<String> infos) {
    String first = infos.removeAt(0);
    switch (first) {
      case 'depth':
        String msg = infos.removeAt(0);
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

  void stop() {
    add(GameLoadEvent(-1));
    isStop = true;
    engine.stop();
    //currentStep = 0;

    add(GameLockEvent(true));
  }

  void newGame([String fen = ChessManual.startFen]) {
    stop();

    add(GameStepEvent('clear'));
    add(GameEngineEvent('clear'));
    manual = ChessManual(fen: fen);
    rule = ChessRule(manual.currentFen);
    hands[0].title = manual.red;
    hands[0].driverType = DriverType.user;
    hands[1].title = manual.black;
    hands[1].driverType = DriverType.user;
    curHand = manual.startHand;

    add(GameLoadEvent(0));
    next();
  }

  void loadPGN(String pgn) {
    stop();

    _loadPGN(pgn);
    add(GameLoadEvent(0));
    next();
  }

  bool _loadPGN(String pgn) {
    isStop = true;
    engine.stop();

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

    add(GameLoadEvent(0));
    // 加载步数
    if (manual.moveCount > 0) {
      // print(manual.moves);
      add(
        GameStepEvent(
          manual.moves.map<String>((e) => e.toChineseString()).join('\n'),
        ),
      );
    }
    manual.loadHistory(-1);
    rule.fen = manual.currentFen;
    add(GameStepEvent('step'));

    curHand = manual.startHand;
    return true;
  }

  void loadFen(String fen) {
    newGame(fen);
  }

  // 重载历史局面
  void loadHistory(int index) {
    if (index >= manual.moveCount) {
      logger.info('History error');
      return;
    }
    if (index == _currentStep) {
      logger.info('History no change');
      return;
    }
    _currentStep = index;
    manual.loadHistory(index);
    rule.fen = manual.currentFen;
    curHand = (_currentStep + 1) % 2;
    add(GamePlayerEvent(curHand));
    add(GameLoadEvent(_currentStep + 1));

    logger.info('history $_currentStep');
  }

  /// 切换驱动
  void switchDriver(int team, DriverType driverType) {
    hands[team].driverType = driverType;
    if (team == curHand && driverType == DriverType.robot) {
      //add(GameLockEvent(true));
      next();
    } else if (driverType == DriverType.user) {
      //add(GameLockEvent(false));
    }
  }

  /// 调用对应的玩家开始下一步
  Future<void> next() async {
    final move = await player.move();
    if (move == null) return;

    addMove(move);
    final canNext = checkResult(curHand == 0 ? 1 : 0, _currentStep - 1);
    logger.info('canNext $canNext');
    if (canNext) {
      switchPlayer();
    }
  }

  /// 从用户落着 TODO 检查出发点是否有子，检查落点是否对方子
  void addStep(ChessPos from, ChessPos next) async {
    player.completeMove('${from.toCode()}${next.toCode()}');
  }

  void addMove(String move) {
    logger.info('addmove $move');
    if (PlayerDriver.isAction(move)) {
      if (move == PlayerDriver.rstGiveUp) {
        setResult(
          curHand == 0 ? ChessManual.resultFstLoose : ChessManual.resultFstWin,
          '${player.title}认输',
        );
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

    // 如果当前不是最后一步，移除后面着法
    if (!manual.isLast) {
      add(GameLoadEvent(-2));
      add(GameStepEvent('clear'));
      manual.addMove(move, addStep: _currentStep);
    } else {
      add(GameLoadEvent(-2));
      manual.addMove(move);
    }
    _currentStep = manual.currentStep;

    final curMove = manual.currentMove!;

    if (curMove.isCheckMate) {
      unEatCount++;
      Sound.play(Sound.move);
    } else if (curMove.isEat) {
      unEatCount = 0;
      Sound.play(Sound.capture);
    } else {
      unEatCount++;
      Sound.play(Sound.move);
    }

    add(GameStepEvent(curMove.toChineseString()));
  }

  void setResult(String result, [String description = '']) {
    if (!ChessManual.results.contains(result)) {
      logger.info('结果不合法 $result');
      return;
    }
    logger.info('本局结果：$result');
    add(GameResultEvent('$result $description'));
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
  bool checkResult(int hand, int curMove) {
    logger.info('checkResult');

    int repeatRound = manual.repeatRound();
    if (repeatRound > 2) {
      // TODO 提醒
    }

    // 判断和棋
    if (unEatCount >= 120) {
      setResult(ChessManual.resultFstDraw, '60回合无吃子判和');
      return false;
    }

    //isCheckMate = rule.isCheck(hand);
    final moveStep = manual.currentMove!;
    logger.info('是否将军 ${moveStep.isCheckMate}');

    // 判断输赢，包括能否应将，长将
    if (moveStep.isCheckMate) {
      //manual.moves[curMove].isCheckMate = isCheckMate;

      if (rule.canParryKill(hand)) {
        // 长将
        if (repeatRound > 3) {
          setResult(
            hand == 0 ? ChessManual.resultFstLoose : ChessManual.resultFstWin,
            '不变招长将作负',
          );
          return false;
        }
        Sound.play(Sound.check);
        add(GameResultEvent('checkMate'));
      } else {
        setResult(
          hand == 0 ? ChessManual.resultFstLoose : ChessManual.resultFstWin,
          '绝杀',
        );
        return false;
      }
    } else {
      if (rule.isTrapped(hand)) {
        setResult(
          hand == 0 ? ChessManual.resultFstLoose : ChessManual.resultFstWin,
          '困毙',
        );
        return false;
      } else if (moveStep.isEat) {
        add(GameResultEvent('eat'));
      }
    }

    // TODO 判断长捉，一捉一将，一将一杀
    if (repeatRound > 3) {
      setResult(ChessManual.resultFstDraw, '不变招判和');
      return false;
    }
    return true;
  }

  List<String> getSteps() {
    return manual.moves.map<String>((cs) => cs.toChineseString()).toList();
  }

  void dispose() {
    engine.stop();
    engine.quit();
  }

  void switchPlayer() {
    curHand++;
    if (curHand >= hands.length) {
      curHand = 0;
    }
    add(GamePlayerEvent(curHand));

    logger.info('切换选手:${player.title} ${player.team} ${player.driver}');

    logger.info(player.title);
    next();
    add(GameEngineEvent('clear'));
  }

  Future<bool> startEngine() {
    return engine.init();
  }

  void requestHelp() {
    if (engine.started) {
      isStop = true;
      engine.stop();
      engine.position(fenStr);
      engine.go(depth: 10);
    } else {
      engine.init().then((value) {
        if (value) {
          requestHelp();
        }
      });
      logger.info('engine is not started');
    }
  }

  String get fenStr => '${manual.currentFen.fen} ${curHand > 0 ? 'b' : 'w'}'
      ' - - $unEatCount ${manual.moveCount ~/ 2}';

  Player get player => hands[curHand];

  Player getPlayer(int hand) => hands[hand];
}
