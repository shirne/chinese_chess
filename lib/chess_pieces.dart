import 'package:flutter/cupertino.dart';

import 'chess.dart';
import 'elements/piece.dart';
import 'models/chess_item.dart';

class ChessPieces extends StatefulWidget {
  final List<ChessItem> items;
  final ChessItem activeItem;

  const ChessPieces({
    Key key,
    this.items,
    this.activeItem,
  }) : super(key: key);

  @override
  State<ChessPieces> createState() => _ChessPiecesState();
}

class _ChessPiecesState extends State<ChessPieces> {
  ChessState chess;
  int curTeam = -1;

  @override
  void initState() {
    super.initState();
    chess = context.findAncestorStateOfType<ChessState>();
    chess.gamer.playerNotifier.addListener(onChangePlayer);
    curTeam = chess.gamer.curHand;
  }

  void onChangePlayer(){
    setState(() {
      curTeam = chess.gamer.playerNotifier.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment(0, 0),
      fit: StackFit.expand,
      children: widget.items.map<Widget>((ChessItem item) {
        bool isActive = false;
        bool isHover = false;
        if (item.isBlank) {
          //return;
        } else if (widget.activeItem != null) {
          if (widget.activeItem.position == item.position) {
            isActive = true;
            if(curTeam == item.team){
              isHover = true;
            }
          }
        }

        return AnimatedAlign(
          duration: Duration(milliseconds: 250),
          curve: Curves.easeOutQuint,
          alignment: chess.gamer.skin.getAlign(item.position),
          child: Container(
            width: chess.gamer.skin.size,
            height: chess.gamer.skin.size,
            //transform: isActive && lastPosition.isEmpty ? Matrix4(1, 0, 0, 0.0, -0.105 * skewStepper, 1 - skewStepper*0.1, 0, -0.004 * skewStepper, 0, 0, 1, 0, 0, 0, 0, 1) : Matrix4.identity(),
            child: Piece(
              item: item,
              isHover: isHover,
              isActive: isActive,
            ),
          ),
        );
      }).toList(),
    );
  }
}
