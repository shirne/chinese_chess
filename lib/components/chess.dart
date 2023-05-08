import 'dart:async';

import 'package:cchess/cchess.dart';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'package:flutter/material.dart';

import 'action_dialog.dart';
import 'board.dart';
import 'piece.dart';
import 'chess_pieces.dart';
import 'mark_component.dart';
import 'point_component.dart';
import '../global.dart';
import '../models/game_event.dart';
import '../models/sound.dart';
import '../models/game_manager.dart';
import '../driver/player_driver.dart';
import '../widgets/game_wrapper.dart';

class Chess extends StatefulWidget {
  final String skin;

  const Chess({Key? key, this.skin = 'woods'}) : super(key: key);

  @override
  State<Chess> createState() => ChessState();
}

class ChessState extends State<Chess> {
  // 当前激活的子
  ChessItem? activeItem;
  double skewStepper = 0;

  // 被吃的子
  ChessItem? dieFlash;

  // 刚走过的位置
  String lastPosition = 'a0';

  // 可落点，包括吃子点
  List<String> movePoints = [];
  bool isInit = false;
  late GameManager gamer;
  bool isLoading = true;

  // 棋局初始化时所有的子力
  List<ChessItem> items = [];

  @override
  void initState() {
    super.initState();
    initGamer();
  }

  void initGamer() {
    if (isInit) return;
    isInit = true;
    GameWrapperState? gameWrapper =
        context.findAncestorStateOfType<GameWrapperState>();
    if (gameWrapper == null) return;
    gamer = gameWrapper.gamer;

    gamer.on<GameLoadEvent>(reloadGame);
    gamer.on<GameResultEvent>(onResult);
    gamer.on<GameMoveEvent>(onMove);
    gamer.on<GameFlipEvent>(onFlip);

    reloadGame(GameLoadEvent(0));
  }

  @override
  void dispose() {
    gamer.off<GameLoadEvent>(reloadGame);
    gamer.off<GameResultEvent>(onResult);
    gamer.off<GameMoveEvent>(onMove);
    super.dispose();
  }

  void onFlip(GameEvent event) {
    setState(() {});
  }

  void onResult(GameEvent event) {
    if (event.data == null || event.data!.isEmpty) {
      return;
    }
    List<String> parts = event.data.split(' ');
    String? resultText =
        (parts.length > 1 && parts[1].isNotEmpty) ? parts[1] : null;
    switch (parts[0]) {
      case 'checkMate':
        //toast(context.l10n.check);
        showAction(ActionType.checkMate);
        break;
      case 'eat':
        showAction(ActionType.eat);
        break;
      case ChessManual.resultFstLoose:
        alertResult(resultText ?? context.l10n.redLoose);
        break;
      case ChessManual.resultFstWin:
        alertResult(resultText ?? context.l10n.redWin);
        break;
      case ChessManual.resultFstDraw:
        alertResult(resultText ?? context.l10n.redDraw);
        break;
      default:
        break;
    }
  }

  void reloadGame(GameEvent event) {
    if (event.data < -1) {
      return;
    }
    if (event.data < 0) {
      if (!isLoading) {
        setState(() {
          isLoading = true;
        });
      }
      return;
    }
    setState(() {
      items = gamer.manual.getChessItems();
      isLoading = false;
      lastPosition = '';
      activeItem = null;
    });
    String position = gamer.lastMove;
    if (position.isNotEmpty) {
      logger.info('last move $position');
      Future.delayed(const Duration(milliseconds: 32)).then((value) {
        setState(() {
          lastPosition = position.substring(0, 2);
          ChessPos activePos = ChessPos.fromCode(position.substring(2, 4));
          activeItem = items.firstWhere(
            (item) =>
                !item.isBlank &&
                item.position == ChessPos.fromCode(lastPosition),
            orElse: () => ChessItem('0'),
          );
          activeItem!.position = activePos;
        });
      });
    }
  }

  void addStep(ChessPos chess, ChessPos next) {
    gamer.addStep(chess, next);
  }

  Future<void> fetchMovePoints() async {
    setState(() {
      movePoints = gamer.rule.movePoints(activeItem!.position);
      // print('move points: $movePoints');
    });
  }

  /// 从外部过来的指令
  void onMove(GameEvent event) {
    PlayerAction action = event.data!;
    logger.info('onmove $action');
    String? move = action.move;
    if (action.type != PlayerActionType.rstMove) {
      if (action.type == PlayerActionType.rstGiveUp) return;
      if (action.type == PlayerActionType.rstRqstDraw) {
        toast(
          context.l10n.requestDraw,
          SnackBarAction(
            label: context.l10n.agreeToDraw,
            onPressed: () {
              gamer.player.completeMove(
                PlayerAction(type: PlayerActionType.rstDraw),
              );
            },
          ),
          5,
        );
      }
      if (action.type == PlayerActionType.rstRqstRetract) {
        confirm(
          context.l10n.requestRetract,
          context.l10n.agreeRetract,
          context.l10n.disagreeRetract,
        ).then((bool? isAgree) {
          gamer.player.completeMove(
            PlayerAction(
              type: isAgree == true
                  ? PlayerActionType.rstRetract
                  : PlayerActionType.rjctRetract,
            ),
          );
        });
      }
    }

    if (move == null || move.isEmpty) {
      return;
    }

    ChessPos fromPos = ChessPos.fromCode(move.substring(0, 2));
    ChessPos toPosition = ChessPos.fromCode(move.substring(2, 4));
    activeItem = items.firstWhere(
      (item) => !item.isBlank && item.position == fromPos,
      orElse: () => ChessItem('0'),
    );
    ChessItem newActive = items.firstWhere(
      (item) => !item.isBlank && item.position == toPosition,
      orElse: () => ChessItem('0'),
    );
    setState(() {
      if (activeItem != null && !activeItem!.isBlank) {
        logger.info('$activeItem => $move');

        activeItem!.position = ChessPos.fromCode(move.substring(2, 4));
        lastPosition = fromPos.toCode();

        if (!newActive.isBlank) {
          logger.info('eat $newActive');

          //showAction(ActionType.eat);
          // 被吃的子的快照
          dieFlash = ChessItem(newActive.code, position: toPosition);
          newActive.isDie = true;
          Future.delayed(const Duration(milliseconds: 250), () {
            setState(() {
              dieFlash = null;
            });
          });
        }
      } else {
        logger.info('Remote move error $move');
      }
    });
  }

  void animateMove(ChessPos nextPosition) {
    logger.info('$activeItem => $nextPosition');
    setState(() {
      activeItem!.position = nextPosition.copy();
    });
  }

  void clearActive() {
    setState(() {
      activeItem = null;
      lastPosition = '';
    });
  }

  /// 检测用户的输入位置是否有效
  Future<bool> checkCanMove(
    String activePos,
    ChessPos toPosition, [
    ChessItem? toItem,
  ]) async {
    if (!movePoints.contains(toPosition.toCode())) {
      if (toItem != null) {
        toast('can\'t eat ${toItem.code} at $toPosition');
      } else {
        toast('can\'t move to $toPosition');
      }
      return false;
    }
    String move = activePos + toPosition.toCode();
    ChessRule rule = ChessRule(gamer.fen.copy());
    rule.fen.move(move);
    if (rule.isKingMeet(gamer.curHand)) {
      toast(context.l10n.cantSendCheck);
      return false;
    }

    // 区分应将和送将
    if (rule.isCheck(gamer.curHand)) {
      if (gamer.isCheckMate) {
        toast(context.l10n.plsParryCheck);
      } else {
        toast(context.l10n.cantSendCheck);
      }
      return false;
    }
    return true;
  }

  /// 用户点击棋盘位置的反馈 包括选中子，走子，吃子，无反馈
  bool onPointer(ChessPos toPosition) {
    ChessItem newActive = items.firstWhere(
      (item) => !item.isBlank && item.position == toPosition,
      orElse: () => ChessItem('0'),
    );

    int ticker = DateTime.now().millisecondsSinceEpoch;
    // 走子
    if (newActive.isBlank) {
      if (activeItem != null && activeItem!.team == gamer.curHand) {
        String activePos = activeItem!.position.toCode();
        animateMove(toPosition);
        checkCanMove(activePos, toPosition).then((canMove) {
          int delay = 250 - (DateTime.now().millisecondsSinceEpoch - ticker);
          if (delay < 0) {
            delay = 0;
          }
          if (canMove) {
            // 立即更新的部分
            setState(() {
              // 清掉落子点
              movePoints = [];
              lastPosition = activePos;
            });

            addStep(ChessPos.fromCode(activePos), toPosition);
          } else {
            Future.delayed(Duration(milliseconds: delay), () {
              setState(() {
                activeItem!.position = ChessPos.fromCode(activePos);
              });
            });
          }
        });

        return true;
      }
      return false;
    }

    if (activeItem != null && activeItem!.position == toPosition) {
      Sound.play(Sound.click);
      // 放下
      setState(() {
        activeItem = null;
        lastPosition = '';
        movePoints = [];
      });
    } else if (newActive.team == gamer.curHand) {
      Sound.play(Sound.click);
      // 切换选中的子
      setState(() {
        activeItem = newActive;
        lastPosition = '';
        movePoints = [];
      });
      fetchMovePoints();
      return true;
    } else {
      // 吃对方的子
      if (activeItem != null && activeItem!.team == gamer.curHand) {
        String activePos = activeItem!.position.toCode();
        animateMove(toPosition);
        checkCanMove(activePos, toPosition, newActive).then((canMove) {
          int delay = 250 - (DateTime.now().millisecondsSinceEpoch - ticker);
          if (delay < 0) {
            delay = 0;
          }
          if (canMove) {
            addStep(ChessPos.fromCode(activePos), toPosition);
            //showAction(ActionType.eat);
            setState(() {
              // 清掉落子点
              movePoints = [];
              lastPosition = activePos;

              // 被吃的子的快照
              dieFlash = ChessItem(newActive.code, position: toPosition);
              newActive.isDie = true;
            });
            Future.delayed(Duration(milliseconds: delay), () {
              setState(() {
                dieFlash = null;
              });
            });
          } else {
            Future.delayed(Duration(milliseconds: delay), () {
              setState(() {
                activeItem!.position = ChessPos.fromCode(activePos);
              });
            });
          }
        });
        return true;
      }
    }
    return false;
  }

  ChessPos pointTrans(Offset tapPoint) {
    int x = (tapPoint.dx - gamer.skin.offset.dx * gamer.scale) ~/
        (gamer.skin.size * gamer.scale);
    int y = 9 -
        (tapPoint.dy - gamer.skin.offset.dy * gamer.scale) ~/
            (gamer.skin.size * gamer.scale);
    return ChessPos(gamer.isFlip ? 8 - x : x, gamer.isFlip ? 9 - y : y);
  }

  void toast(String message, [SnackBarAction? action, int duration = 3]) {
    MyDialog.snack(
      message,
      action: action,
      duration: Duration(seconds: duration),
    );
  }

  void alertResult(message) {
    confirm(message, context.l10n.oneMoreGame, context.l10n.letMeSee)
        .then((isConfirm) {
      if (isConfirm ?? false) {
        gamer.newGame();
      }
    });
  }

  Future<bool?> confirm(String message, String agreeText, String cancelText) {
    return MyDialog.confirm(
      message,
      buttonText: agreeText,
      cancelText: cancelText,
    );
  }

  Future<bool?> alert(String message) async {
    return MyDialog.alert(message);
  }

  // 显示吃/将效果
  void showAction(ActionType type) {
    final overlay = Overlay.of(context);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Center(
        child: ActionDialog(
          type,
          delay: 2,
          onHide: () {
            entry.remove();
          },
        ),
      ),
    );
    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    List<Widget> widgets = [const Board()];

    List<Widget> layer0 = [];
    if (dieFlash != null) {
      layer0.add(
        Align(
          alignment: gamer.skin.getAlign(dieFlash!.position),
          child: Piece(item: dieFlash!, isActive: false, isAblePoint: false),
        ),
      );
    }
    if (lastPosition.isNotEmpty) {
      ChessItem emptyItem =
          ChessItem('0', position: ChessPos.fromCode(lastPosition));
      layer0.add(
        Align(
          alignment: gamer.skin.getAlign(emptyItem.position),
          child: MarkComponent(
            size: gamer.skin.size * gamer.scale,
          ),
        ),
      );
    }
    widgets.add(
      Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: layer0,
      ),
    );

    widgets.add(
      ChessPieces(
        items: items,
        activeItem: activeItem,
      ),
    );

    List<Widget> layer2 = [];
    for (var element in movePoints) {
      ChessItem emptyItem =
          ChessItem('0', position: ChessPos.fromCode(element));
      layer2.add(
        Align(
          alignment: gamer.skin.getAlign(emptyItem.position),
          child: PointComponent(size: gamer.skin.size * gamer.scale),
        ),
      );
    }
    widgets.add(
      Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: layer2,
      ),
    );

    return GestureDetector(
      onTapUp: (detail) {
        if (gamer.isLock) return;
        setState(() {
          onPointer(pointTrans(detail.localPosition));
        });
      },
      child: SizedBox(
        width: gamer.skin.width,
        height: gamer.skin.height,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: widgets,
        ),
      ),
    );
  }
}
