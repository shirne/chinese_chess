
import 'package:chinese_chess/game.dart';
import 'package:flutter/material.dart';

import 'elements/board.dart';
import 'models/chess_map.dart';
import 'elements/piece.dart';
import 'models/game_manager.dart';

class Chess extends StatefulWidget {
  final String skin;

  const Chess(
      {Key key,
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

  // 当前激活子
  ChessItem activePiece;
  // 被吃的子
  ChessItem dieFlash;

  // 刚走过的位置
  String lastPosition = 'a0';

  // 可落点，包括吃子点
  List<String> movePoints=[];
  GameManager gamer;

  @override
  void initState() {
    super.initState();
    GameWrapperState gameWrapper = context.findAncestorStateOfType<GameWrapperState>();
    gamer = gameWrapper.gamer;
    gamer.gameNotifier.addListener(reloadGame);
  }

  reloadGame(){
    if(gamer.gameNotifier.value < 0){
      return;
    }
    String position = gamer.steps[gamer.currentStep].move;
    setState(() {
      activePiece = gamer.map.getChessAt(XYKey.fromCode(position.substring(2,3)));
      lastPosition = position.substring(0,1);
    });
  }

  addStep(ChessItem chess, ChessItem next){
    gamer.addStep(chess, next);
  }

  fetchMovePoints(){
    movePoints = gamer.rule.movePoints(activePiece, gamer.map);
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
  bool setActive(ChessItem newActive){
    // 没有激活的子，或者激活的子不是当前选手的
    if(activePiece == null || activePiece.team != gamer.player.team) {
      if(newActive.team != gamer.player.team){
        return false;
      }
      setState(() {
        activePiece = newActive;
        lastPosition = '';
        movePoints = [];
      });
      fetchMovePoints();
      return true;
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
          alert('can\'t eat ${newActive.team}${newActive.code} at ${newActive.position}');
          return false;
        }
        addStep(activePiece, newActive);
        dieFlash = ChessItem(team:newActive.team,code:newActive.code,position: newActive.position);
        animateMove(newActive).then((arg){
          dieFlash = null;
          setState(() {
            newActive.position = activePiece.position;
            activePiece.position = lastPosition;
            gamer.map.eat(activePiece, newActive);
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
        return true;
      }
    }
    return false;
  }

  void setNext(ChessItem next){

    // 当前选中的子是当前选手的
    if(activePiece != null && activePiece.team == gamer.player.team){
      if(!movePoints.contains(next.position)){
        alert('can\'t move to ${next.position}');
        return;
      }
      addStep(activePiece, next);
      animateMove(next).then((arg) {
        setState(() {
          next.position = activePiece.position;
          activePiece.position = lastPosition;
          gamer.map.move(activePiece, next);
        });
        // 走棋，切换选手
        gamer.switchPlayer();
      });
    }
  }

  void alert(String message){
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
    gamer.map.forEach((XYKey key, ChessItem item) {
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
            child: AnimatedContainer(
              width: pieceSize,
              height: pieceSize,
              transform: isActive && lastPosition.isEmpty ? Matrix4(1, 0, 0, 0.0, -0.105, 0.9, 0, -0.004, 0, 0, 1, 0, 0, 0, 0, 1) : Matrix4.identity(),
              duration: Duration(milliseconds: 250),
              curve: Curves.easeOutQuint,
              child:  Piece(item:item, isActive: isActive, isAblePoint: isAblePoint,),
            ),
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
