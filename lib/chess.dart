
import 'package:chinese_chess/chess_pieces.dart';
import 'package:chinese_chess/elements/mark_component.dart';
import 'package:chinese_chess/elements/point_component.dart';
import 'package:chinese_chess/game.dart';
import 'package:flutter/material.dart';

import 'elements/board.dart';
import 'models/chess_item.dart';
import 'elements/piece.dart';
import 'models/chess_pos.dart';
import 'models/chess_rule.dart';
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

  // 当前激活的子
  ChessItem activeItem;
  double skewStepper = 0;

  // 被吃的子
  ChessItem dieFlash;

  // 刚走过的位置
  String lastPosition = 'a0';

  // 可落点，包括吃子点
  List<String> movePoints=[];
  GameManager gamer;
  bool isLoading = true;

  // 棋局初始化时所有的子力
  List<ChessItem> items = [];

  @override
  void initState() {
    super.initState();
    GameWrapperState gameWrapper = context.findAncestorStateOfType<GameWrapperState>();
    gamer = gameWrapper.gamer;
    gamer.gameNotifier.addListener(reloadGame);
  }

  @override
  void dispose() {

    super.dispose();
  }

  reloadGame(){
    if(gamer.gameNotifier.value < 0){
      if(!isLoading) {
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
    if(position.isNotEmpty) {
      print('last move $position');
      Future.delayed(Duration(milliseconds: 32)).then((value){
        setState(() {
          lastPosition = position.substring(0, 2);
          ChessPos activePos = ChessPos.fromCode(position.substring(2, 4));
          activeItem = items.firstWhere((item) => !item.isBlank &&
              item.position == ChessPos.fromCode(lastPosition), orElse: () => ChessItem('0'));
          activeItem.position = activePos;
        });
      });
    }
  }

  addStep(ChessPos chess, ChessPos next){
    gamer.addStep(chess, next);
  }

  fetchMovePoints() async{

    setState(() {
      movePoints = gamer.rule.movePoints(activeItem.position);
      print('move points: $movePoints');
    });

  }

  Future animateMove(ChessPos nextPosition) async{

    setState(() {
      activeItem.position = nextPosition.copy();
    });
    return Future.delayed(Duration(milliseconds: 300));
  }

  clearActive(){
    setState(() {
      activeItem = null;
      lastPosition = '';
    });
  }

  Future<bool> checkCanMove(String activePos, ChessPos toPosition, [ChessItem toItem]) async{
    if (!movePoints.contains(toPosition.toCode())) {
      if(toItem != null){
        alert('can\'t eat ${toItem.code} at $toPosition');
      }else {
        alert('can\'t move to $toPosition');
      }
      return false;
    }
    String move = activePos+toPosition.toCode();
    ChessRule rule = ChessRule(gamer.fen.copy());
    rule.fen.move(move);
    if(rule.isKingMeet(gamer.curHand)){
      alert('不能送将');
      return false;
    }

    /// todo 这里送将和应将判断不准确
    if(rule.isCheckMate(gamer.curHand)){
      if(gamer.isCheckMate) {
        alert('请应将');
      }else{
        alert('不能送将');
      }
      return false;
    }
    return true;
  }

  bool setActive(ChessPos toPosition){
    ChessItem newActive = items.firstWhere((item) => !item.isBlank && item.position == toPosition, orElse:()=> ChessItem('0'));

    int ticker = DateTime.now().millisecondsSinceEpoch;
    if((newActive == null || newActive.isBlank) ){
      if(activeItem != null && activeItem.team == gamer.curHand) {
        String activePos = activeItem.position.toCode();
        animateMove(toPosition);
        checkCanMove(activePos, toPosition).then((canMove){
          int delay = 250 - (DateTime.now().millisecondsSinceEpoch - ticker);
          if(delay < 0){
            delay = 0;
          }
          if(canMove){
            // 立即更新的部分
            setState(() {
              // 清掉落子点
              movePoints = [];
              lastPosition = activePos;
            });

            addStep(ChessPos.fromCode(activePos), toPosition);
            gamer.switchPlayer();
          }else{
            Future.delayed(Duration(milliseconds: delay),(){
              setState(() {
                activeItem.position = ChessPos.fromCode(activePos);
              });
            });
          }
        });

        return true;
      }
      return false;
    }

    // 置空当前选中状态
    if(activeItem != null && activeItem.position == toPosition){
      setState(() {
        activeItem = null;
        lastPosition = '';
        movePoints = [];
      });
    }else if(newActive.team == gamer.curHand ) {
      // 切换选中的子
      setState(() {
        activeItem = newActive;
        lastPosition = '';
        movePoints = [];
      });
      fetchMovePoints();
      return true;
    }else {
      // 吃对方的子
      if(activeItem != null && activeItem.team == gamer.curHand){
        String activePos = activeItem.position.toCode();
        animateMove(toPosition);
        checkCanMove(activePos, toPosition, newActive).then((canMove){
          int delay = 250 - (DateTime.now().millisecondsSinceEpoch - ticker);
          if(delay < 0){
            delay = 0;
          }
          if(canMove){
            addStep(ChessPos.fromCode(activePos), toPosition);
            setState(() {
              // 清掉落子点
              movePoints = [];
              lastPosition = activePos;

              // 被吃的子的快照
              dieFlash = ChessItem(newActive.code, position:toPosition);
              newActive.isDie = true;
            });
            Future.delayed(Duration(milliseconds: delay),(){
              setState(() {
                dieFlash = null;
              });

              // 吃子，切换选手
              gamer.switchPlayer();
            });
          }else{
            Future.delayed(Duration(milliseconds: delay),(){
              setState(() {
                activeItem.position = ChessPos.fromCode(activePos);
              });
            });
          }
        });
        return true;
      }
    }
    return false;
  }

  ChessPos pointTrans(Offset tapPoint){
    int x = (tapPoint.dx - gamer.skin.offset.dx) ~/ gamer.skin.size;
    int y = 9 - (tapPoint.dy - gamer.skin.offset.dy) ~/ gamer.skin.size;
    return ChessPos(x, y);
  }

  void alert(String message){
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if(isLoading){
      return Center(child: CircularProgressIndicator(),);
    }

    List<Widget> widgets = [Board()];

    List<Widget> layer0 = [];
    if(dieFlash != null) {
      layer0.add(Align(
        alignment: gamer.skin.getAlign(dieFlash.position),
        child: Piece(item: dieFlash, isActive: false, isAblePoint: false),
      ));
    }
    if(lastPosition.isNotEmpty){
      ChessItem emptyItem = ChessItem('0', position: ChessPos.fromCode(lastPosition));
      layer0.add(Align(
        alignment: gamer.skin.getAlign(emptyItem.position),
        child: MarkComponent(size: gamer.skin.size,),
      ));
    }
    widgets.add(Stack(
      alignment: Alignment(0, 0),
      fit: StackFit.expand,
      children: layer0,
    ));

    widgets.add(ChessPieces(items: items,activeItem: activeItem,));

    List<Widget> layer2 = [];
    movePoints.forEach((element) {
      ChessItem emptyItem = ChessItem('0', position: ChessPos.fromCode(element));
      layer2.add(Align(
        alignment: gamer.skin.getAlign(emptyItem.position),
        child: PointComponent(size:gamer.skin.size),
      ));
    });
    widgets.add(Stack(
      alignment: Alignment(0, 0),
      fit: StackFit.expand,
      children: layer2,
    ));


    return GestureDetector(
      onTapUp: (detail){
        setState(() {
          setActive(pointTrans(detail.localPosition));
        });
      },
      child: Container(
        width: gamer.skin.width,
        height: gamer.skin.height,
        child: Stack(
          alignment: Alignment(0, 0),
          fit: StackFit.expand,
          children: widgets,
        ),
      ),
    ) ;
  }

}
