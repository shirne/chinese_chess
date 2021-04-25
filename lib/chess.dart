
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

  // 布局
  ChessMap map = ChessMap();

  // 走步历史
  List<ChessStep> steps = [];

  // 当前激活子
  ChessItem activePiece;
  // 被吃的子
  ChessItem dieFlash;

  // 刚走过的位置
  String lastPosition = 'a0';

  // 可落点，包括吃子点
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

  Future animateMove(ChessItem next) async{
    setState(() {
      // 清掉落子点
      movePoints = [];
      lastPosition = activePiece.position;
      activePiece.position = next.position;
      next.isBlank = true;
      next.position = lastPosition;
    });
    return Future.delayed(Duration(milliseconds: 300));
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
        dieFlash = ChessItem(team:newActive.team,code:newActive.code,position: newActive.position);
        animateMove(newActive).then((arg){
          dieFlash = null;
          setState(() {
            newActive.position = activePiece.position;
            activePiece.position = lastPosition;
            map.eat(activePiece, newActive);
          });
          // 吃子，切换选手
          gamer.switchPlayer();
        });

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
      animateMove(next).then((arg) {
        setState(() {
          next.position = activePiece.position;
          activePiece.position = lastPosition;
          map.move(activePiece, next);
        });
        // 走棋，切换选手
        gamer.switchPlayer();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [Board()];

    if(dieFlash != null) {
      widgets.add(Align(
        alignment: Alignment(
          (dieFlash.x * cellSize * 2 + 8) / boardWidth - 1,
          ((9 - dieFlash.y) * cellSize * 2 + 2) / boardHeight - 1,
        ),
        child: Piece(item: dieFlash, isActive: false, isAblePoint: false),
      ));
    }
    map.forEach((XYKey key, ChessItem item) {
      bool isActive = false;
      bool isAblePoint = false;
      if(movePoints.contains(item.position)){
        isAblePoint = true;
      }
      if(item.isBlank){
        if(lastPosition == item.position){
          isActive = true;
        }
      }else{
        if(activePiece == item){
          isActive = true;
          widgets.add(AnimatedAlign(
            duration: Duration(milliseconds: 250),
            curve: Curves.easeOutQuint,
            alignment: Alignment(
              (item.x * cellSize * 2 + 8) / boardWidth - 1,
              ( (9 - item.y) * cellSize * 2 + 2) / boardHeight - 1,
            ),
            child: Piece(item:item, isActive: isActive, isAblePoint: isAblePoint),
          ));
          return;
        }
      }
      widgets.add(Align(
        alignment: Alignment(
          (item.x * cellSize * 2 + 8) / boardWidth - 1,
          ( (9 - item.y) * cellSize * 2 + 2) / boardHeight - 1,
        ),
        child: Piece(item:item, isActive: isActive, isAblePoint: isAblePoint),
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
