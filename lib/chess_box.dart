

import 'package:flutter/material.dart';
import 'models/chess_item.dart';

class ChessBox extends StatefulWidget{
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

    );
  }
}