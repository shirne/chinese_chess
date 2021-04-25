
import 'package:chinese_chess/game.dart';
import 'package:chinese_chess/models/chess_rule.dart';
import 'package:flutter/material.dart';

import 'elements/board.dart';
import 'models/Gamer.dart';
import 'models/chess_map.dart';
import 'elements/piece.dart';
import 'models/chess_step.dart';

class Chess extends StatefulWidget {
  final String initFen;
  final String skin;

  const Chess(
      {Key key,
      this.initFen =
          'rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1',
      this.skin = 'woods'})
      : super(key: key);

  @override
  State<Chess> createState() => ChessState();
}

class ChessState extends State<Chess> {
  String pieceSuffix = 'gif';
  String boardSuffix = 'jpg';
  double pieceSize = 57;
  double cellSize = 64;
  double boardWidth = 521;
  double boardHeight = 577;

  ChessMap map = ChessMap();
  List<ChessStep> steps = [];

  ChessItem activePiece;
  String lastPosition = 'a0';
  List<String> movePoints=[];
  Gamer gamer;

  @override
  void initState() {
    super.initState();
    GameWrapperState gameWrapper = context.findAncestorStateOfType<GameWrapperState>();
    gamer = gameWrapper.gamer;
    map.load(widget.initFen);
  }

  addStep(ChessItem chess, ChessItem next){
    steps.add(ChessStep(chess.code, chess.position+next.position, isEat: !next.isBlank));
    print(steps[steps.length-1]);
  }

  fetchMovePoints(){
    movePoints = gamer.rule.movePoints(activePiece,map);
    print(['move points:', movePoints]);
  }

  clearActive(){
    setState(() {
      activePiece = null;
      lastPosition = '';
    });
  }
  void setActive(ChessItem newActive){
    // 没有激活的子，或者激活的子不是当前选手的
    if(activePiece == null || activePiece.team != gamer.player.team) {
      if(newActive.team != gamer.player.team){
        return;
      }
      setState(() {
        activePiece = newActive;
        lastPosition = '';
      });
      fetchMovePoints();
      //置空选中的子
    }else if(activePiece == newActive){
      setState(() {
        activePiece = null;
        lastPosition = '';
        movePoints = [];
      });
    }else {
      // 吃对方的子
      if(newActive.team != gamer.player.team){
        if(!movePoints.contains(newActive.position)){
          print('can\'t eat ${newActive.team}${newActive.code} at ${newActive.position}');
          return;
        }
        addStep(activePiece, newActive);
        setState(() {
          lastPosition = activePiece.position;
          map.eat(activePiece, newActive);
        });
        // 吃子，切换选手
        gamer.switchPlayer();
        // 切换选中的子
      }else{
        setState(() {
          activePiece = newActive;
          lastPosition = '';
          movePoints = [];
        });
        fetchMovePoints();
      }

    }
  }

  void setNext(ChessItem next){

    // 当前选中的子是当前选手的
    if(activePiece != null && activePiece.team == gamer.player.team){
      if(!movePoints.contains(next.position)){
        print('can\'t move to ${next.position}');
        return;
      }
      addStep(activePiece, next);
      setState(() {
        lastPosition = activePiece.position;
        map.move(activePiece, next);
      });
      // 走棋，切换选手
      gamer.switchPlayer();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [Board()];
    map.forEach((XYKey key, ChessItem item) {
      widgets.add(Align(
        alignment: Alignment(
          (item.x * cellSize * 2 + 4) / boardWidth - 1,
          ( (9 - item.y) * cellSize * 2 + 2) / boardHeight - 1,
        ),
        child: Piece(item:item, isActive: (item.isBlank? lastPosition == item.position :activePiece == item),),
      ));
    });

    return Container(
      width: boardWidth,
      height: boardHeight,
      child: Stack(
        alignment: Alignment(0, 0),
        fit: StackFit.expand,
        children: widgets,
      ),
    );
  }
}
