import 'package:cchess/cchess.dart';
import 'package:flutter/material.dart';

import 'chess_box.dart';
import 'chess_pieces.dart';
import 'chess_single_box.dart';
import 'board.dart';
import '../global.dart';
import '../widgets/game_wrapper.dart';
import '../models/game_manager.dart';

/// 编辑局面
class EditFen extends StatefulWidget {
  final String fen;

  const EditFen({super.key, required this.fen});

  @override
  State<EditFen> createState() => EditFenState();
}

class EditFenState extends State<EditFen> {
  late ChessManual manual;
  GameManager? gamer;
  late List<ChessItem> items;
  ChessItem? activeItem;
  String activeChr = '';
  String dieChrs = '';

  @override
  void initState() {
    super.initState();
    manual = ChessManual();

    manual.setFen(widget.fen);
    items = manual.getChessItems();
    dieChrs = manual.currentFen.getDieChr();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void editOK() {
    Navigator.of(context).pop<String>(manual.currentFen.fen);
  }

  bool onPointer(ChessPos toPosition) {
    ChessItem targetItem = items.firstWhere(
      (item) => !item.isBlank && item.position == toPosition,
      orElse: () => ChessItem('0'),
    );
    if (targetItem.isBlank) {
      if (activeItem != null) {
        manual.doMove('${activeItem!.position.toCode()}${toPosition.toCode()}');
        setState(() {
          activeItem!.position = toPosition;
          activeItem = null;
        });
        return true;
      } else if (activeChr.isNotEmpty) {
        manual.setItem(toPosition, activeChr);
        setState(() {
          items = manual.getChessItems();
          activeChr = '';
          dieChrs = manual.currentFen.getDieChr();
        });
        return true;
      }
    } else {
      if (activeItem != null) {
        if (activeItem!.position == toPosition) {
          manual.setItem(toPosition, '0');
          setState(() {
            items = manual.getChessItems();
            activeItem = null;
            dieChrs = manual.currentFen.getDieChr();
          });
        } else {
          //targetItem.position = ChessPos.fromCode('i4');
          //targetItem.isDie = true;
          manual
              .doMove('${activeItem!.position.toCode()}${toPosition.toCode()}');
          setState(() {
            items = manual.getChessItems();
            activeItem = null;
          });
        }
        return true;
      } else if (activeChr.isNotEmpty && activeChr != targetItem.code) {
        //targetItem.position = ChessPos.fromCode('i4');
        bool seted = manual.setItem(toPosition, activeChr);
        if (seted) {
          setState(() {
            items = manual.getChessItems();
            activeChr = '';
            dieChrs = manual.currentFen.getDieChr();
          });
        }
      } else {
        setState(() {
          activeItem = targetItem;
          activeChr = '';
        });
      }
    }
    return false;
  }

  void removeItem(ChessPos fromPosition) {
    manual.currentFen[fromPosition.y][fromPosition.x] = '0';
    setState(() {
      items = manual.getChessItems();
      activeItem = null;
      activeChr = '';
    });
  }

  void setActiveChr(String chr) {
    setState(() {
      activeItem = null;
      activeChr = chr;
    });
  }

  void clearAll() {
    manual.setFen('4k4/9/9/9/9/9/9/9/9/4K4');
    setState(() {
      items = manual.getChessItems();
      dieChrs = manual.currentFen.getDieChr();
      activeChr = '';
      activeItem = null;
    });
  }

  ChessPos pointTrans(Offset tapPoint) {
    int x = (tapPoint.dx - gamer!.skin.offset.dx * gamer!.scale) ~/
        (gamer!.skin.size * gamer!.scale);
    int y = 9 -
        (tapPoint.dy - gamer!.skin.offset.dy * gamer!.scale) ~/
            (gamer!.skin.size * gamer!.scale);
    return ChessPos(x, y);
  }

  @override
  Widget build(BuildContext context) {
    if (gamer == null) {
      GameWrapperState gameWrapper =
          context.findAncestorStateOfType<GameWrapperState>()!;
      gamer = gameWrapper.gamer;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.editCode),
        actions: [
          TextButton(
            onPressed: () {
              editOK();
            },
            child: Text(
              context.l10n.save,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Center(
        child: gamer!.scale < 1 ? _mobileContainer() : _windowContainer(),
      ),
    );
  }

  Widget _mobileContainer() {
    return SizedBox(
      width: gamer!.skin.width * gamer!.scale,
      height: (gamer!.skin.height + gamer!.skin.size * 2 + 20) * gamer!.scale,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ChessSingleBox(
            width: gamer!.skin.width * gamer!.scale,
            itemChrs: dieChrs,
            activeChr: activeChr,
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTapUp: (detail) {
              onPointer(pointTrans(detail.localPosition));
            },
            onLongPressEnd: (detail) {
              logger.info('longPressEnd $detail');
            },
            onPanEnd: (detail) {},
            child: SizedBox(
              width: gamer!.skin.width * gamer!.scale,
              height: gamer!.skin.height * gamer!.scale,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Board(),
                  ChessPieces(
                    items: items,
                    activeItem: activeItem,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          ChessSingleBox(
            width: gamer!.skin.width * gamer!.scale,
            itemChrs: dieChrs,
            activeChr: activeChr,
          ),
        ],
      ),
    );
  }

  Widget _windowContainer() {
    return SizedBox(
      width: gamer!.skin.width + 10 + gamer!.skin.size * 2 + 10,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTapUp: (detail) {
              onPointer(pointTrans(detail.localPosition));
            },
            onLongPressEnd: (detail) {
              logger.info('longPressEnd $detail');
            },
            onPanEnd: (detail) {},
            child: SizedBox(
              width: gamer!.skin.width,
              height: gamer!.skin.height,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Board(),
                  ChessPieces(
                    items: items,
                    activeItem: activeItem,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          ChessBox(
            height: gamer!.skin.height,
            itemChrs: dieChrs,
            activeChr: activeChr,
          ),
        ],
      ),
    );
  }
}
