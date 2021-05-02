
import 'package:flutter/material.dart';

import 'chess_box.dart';
import 'chess_pieces.dart';
import 'elements/board.dart';
import 'widgets/game_wrapper.dart';
import 'models/game_manager.dart';
import 'models/chess_fen.dart';

class EditFen extends StatefulWidget {
  final String fen;

  const EditFen({Key key, this.fen}) : super(key: key);

  @override
  State<EditFen> createState() => _EditFenState();
}

class _EditFenState extends State<EditFen> {
  ChessFen fen;
  GameManager gamer;

  @override
  initState() {
    super.initState();
    fen = ChessFen(widget.fen);
  }

  @override
  dispose() {
    super.dispose();
  }

  editOK() {
    Navigator.of(context).pop<String>(fen.fen);
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
        title: Text('编辑局面'),
        actions: [
          TextButton(
            onPressed: () {
              editOK();
            },
            child: Text(
              '确定',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: Center(
        child: Container(
          child: Row(
            children: [
              Container(
                width: gamer.skin.width,
                height: gamer.skin.height,
                child: Stack(
                  alignment: Alignment.center,
                  children: [Board(), ChessPieces(items: fen.getAll())],
                ),
              ),
              SizedBox(
                width: 10,
              ),
              ChessBox(items: fen.getDies())
            ],
          ),
        ),
      ),
    );
  }
}
