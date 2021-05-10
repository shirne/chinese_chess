
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'chess_box.dart';
import 'chess_pieces.dart';
import 'chess_single_box.dart';
import 'elements/board.dart';
import 'generated/l10n.dart';
import 'models/chess_item.dart';
import 'models/chess_manual.dart';
import 'models/chess_pos.dart';
import 'widgets/game_wrapper.dart';
import 'models/game_manager.dart';

class EditFen extends StatefulWidget {
  final String fen;

  const EditFen({Key key, this.fen}) : super(key: key);

  @override
  State<EditFen> createState() => EditFenState();
}

class EditFenState extends State<EditFen> {
  ChessManual manual;
  GameManager gamer;
  List<ChessItem> items;
  ChessItem activeItem;
  String activeChr='';
  String dieChrs='';

  @override
  initState() {
    super.initState();
    manual = ChessManual();
    manual.diePosition = ChessPos(9, 5);
    manual.diePositions = {
      'k':ChessPos(9, 9),
      'a':ChessPos(10, 9),
      'b':ChessPos(9, 8),
      'c':ChessPos(10, 8),
      'n':ChessPos(9, 7),
      'r':ChessPos(10, 7),
      'p':ChessPos(9, 6),

      'K':ChessPos(9, 4),
      'A':ChessPos(10, 4),
      'B':ChessPos(9, 3),
      'C':ChessPos(10, 3),
      'N':ChessPos(9, 2),
      'R':ChessPos(10, 2),
      'P':ChessPos(9, 1),
    };
    manual.setFen(widget.fen);
    items = manual.getChessItems();
    dieChrs = manual.currentFen.getDieChr();
  }

  @override
  dispose() {
    super.dispose();
  }

  editOK() {
    Navigator.of(context).pop<String>(manual.currentFen.fen);
  }

  bool onPointer(ChessPos toPosition) {
    ChessItem targetItem = items.firstWhere((item) => !item.isBlank && item.position == toPosition, orElse:()=> ChessItem('0'));
    if(targetItem == null || targetItem.isBlank){
      if(activeItem != null){
        manual.doMove(
            '${activeItem.position.toCode()}${toPosition.toCode()}');
        setState(() {
          activeItem.position = toPosition;
          activeItem = null;
        });
        return true;
      }else if(activeChr.isNotEmpty){
        manual.setItem(toPosition, activeChr);
        setState(() {
          items = manual.getChessItems();
          activeChr = '';
          dieChrs = manual.currentFen.getDieChr();
        });
        return true;
      }
    }else{
      if(activeItem != null) {
        if(activeItem.position == toPosition) {
          manual.setItem(toPosition, '0');
            setState(() {
              items = manual.getChessItems();
              activeItem = null;
              dieChrs = manual.currentFen.getDieChr();
            });

        }else {
          //targetItem.position = ChessPos.fromCode('i4');
          //targetItem.isDie = true;
          manual.doMove(
              '${activeItem.position.toCode()}${toPosition.toCode()}');
          setState(() {
            items = manual.getChessItems();
            activeItem = null;
          });
        }
        return true;
      }else if(activeChr.isNotEmpty && activeChr != targetItem.code) {
          //targetItem.position = ChessPos.fromCode('i4');
        bool seted = manual.setItem(toPosition, activeChr);
        if(seted) {
          setState(() {
            items = manual.getChessItems();
            activeChr = '';
            dieChrs = manual.currentFen.getDieChr();
          });
        }
      }else{
        setState(() {
          activeItem = targetItem;
          activeChr = '';
        });
      }
    }
    return false;
  }

  removeItem(ChessPos fromPosition){
    manual.currentFen[fromPosition.y][fromPosition.x] = '0';
    setState(() {
      items = manual.getChessItems();
      activeItem = null;
      activeChr = '';
    });
  }

  setActiveChr(String chr){
    setState(() {
      activeItem = null;
      activeChr = chr;
    });
  }
  clearAll(){
    manual.setFen('4k4/9/9/9/9/9/9/9/9/4K4');
    setState(() {
      items = manual.getChessItems();
      dieChrs = manual.currentFen.getDieChr();
      activeChr = '';
      activeItem = null;
    });

  }

  ChessPos pointTrans(Offset tapPoint) {
    int x = (tapPoint.dx - gamer.skin.offset.dx * gamer.scale) ~/ (gamer.skin.size * gamer.scale);
    int y = 9 - (tapPoint.dy - gamer.skin.offset.dy * gamer.scale) ~/ (gamer.skin.size * gamer.scale);
    return ChessPos(x, y);
  }

  @override
  Widget build(BuildContext context) {
    if(gamer == null) {
      GameWrapperState gameWrapper =
      context.findAncestorStateOfType<GameWrapperState>();
      gamer = gameWrapper.gamer;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).edit_code),
        actions: [
          TextButton(
            onPressed: () {
              editOK();
            },
            child: Text(
              S.of(context).save,
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: Center(
        child: gamer.scale < 1 ? _mobileContainer() : _windowContainer()
      ),
    );
  }

  Widget _mobileContainer(){
    return Container(
      width: gamer.skin.width * gamer.scale,
      height: (gamer.skin.height + gamer.skin.size * 2 + 20) * gamer.scale,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ChessSingleBox(width:gamer.skin.width * gamer.scale, itemChrs: dieChrs, activeChr:activeChr),
          SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTapUp: (detail){
              onPointer(pointTrans(detail.localPosition));
            },
            onLongPressEnd: (detail){
              print('longPressEnd $detail');

            },
            onPanEnd: (detail){

            },
            child: Container(
              width: gamer.skin.width * gamer.scale,
              height: gamer.skin.height * gamer.scale,
              child: Stack(
                alignment: Alignment.center,
                children: [Board(), ChessPieces(items: items, activeItem: activeItem,)],
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          ChessSingleBox(width:gamer.skin.width * gamer.scale, itemChrs: dieChrs, activeChr:activeChr)
        ],
      ),
    );
  }

  Widget _windowContainer(){
    return Container(
      width: gamer.skin.width + 10 + gamer.skin.size * 2 + 10,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTapUp: (detail){
              onPointer(pointTrans(detail.localPosition));
            },
            onLongPressEnd: (detail){
              print('longPressEnd $detail');

            },
            onPanEnd: (detail){

            },
            child: Container(
              width: gamer.skin.width,
              height: gamer.skin.height,
              child: Stack(
                alignment: Alignment.center,
                children: [Board(), ChessPieces(items: items, activeItem: activeItem,)],
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          ChessBox(height:gamer.skin.height, itemChrs: dieChrs, activeChr:activeChr)
        ],
      ),
    );
  }
}
