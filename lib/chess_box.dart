import 'package:chinese_chess/elements/piece.dart';
import 'package:flutter/material.dart';
import 'models/chess_item.dart';

class ChessBox extends StatefulWidget {
  final List<ChessItem> items;
  final ChessItem activeItem;

  const ChessBox({Key key, this.items, this.activeItem}) : super(key: key);

  @override
  State<ChessBox> createState() => _ChessBoxState();
}

class _ChessBoxState extends State<ChessBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 114,
      child: Flex(
        direction: Axis.vertical,
        children: [
          Wrap(
            children: [
              Stack(
                children: [
                  Piece(
                    item: ChessItem('k'),
                  )
                ],
              ),
              Stack(
                children: [
                  Piece(
                    item: ChessItem('a'),
                  )
                ],
              ),
              Stack(
                children: [
                  Piece(
                    item: ChessItem('b'),
                  )
                ],
              ),
              Stack(
                children: [
                  Piece(
                    item: ChessItem('n'),
                  )
                ],
              ),
              Stack(
                children: [
                  Piece(
                    item: ChessItem('r'),
                  )
                ],
              ),
              Stack(
                children: [
                  Piece(
                    item: ChessItem('c'),
                  )
                ],
              ),
              Stack(
                children: [
                  Piece(
                    item: ChessItem('p'),
                  )
                ],
              )
            ],
          ),
          Wrap(
            children: [
              Stack(
                children: [
                  Piece(
                    item: ChessItem('K'),
                  )
                ],
              ),
              Stack(
                children: [
                  Piece(
                    item: ChessItem('A'),
                  )
                ],
              ),
              Stack(
                children: [
                  Piece(
                    item: ChessItem('B'),
                  )
                ],
              ),
              Stack(
                children: [
                  Piece(
                    item: ChessItem('N'),
                  )
                ],
              ),
              Stack(
                children: [
                  Piece(
                    item: ChessItem('R'),
                  )
                ],
              ),
              Stack(
                children: [
                  Piece(
                    item: ChessItem('C'),
                  )
                ],
              ),
              Stack(
                children: [
                  Piece(
                    item: ChessItem('P'),
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
