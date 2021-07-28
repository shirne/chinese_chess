
import 'package:flutter/material.dart';

import 'edit_fen.dart';
import 'generated/l10n.dart';
import 'models/chess_item.dart';
import 'elements/piece.dart';
import 'models/game_manager.dart';
import 'widgets/game_wrapper.dart';

class ChessBox extends StatefulWidget {
  final String itemChrs;
  final String activeChr;
  final double height;

  const ChessBox({Key? key,required this.itemChrs, this.activeChr = '',required this.height}) : super(key: key);

  @override
  State<ChessBox> createState() => _ChessBoxState();
}

class _ChessBoxState extends State<ChessBox> {
  static const allItemChrs = 'kabcnrp';

  int matchCount(String chr) {
    return RegExp(chr).allMatches(widget.itemChrs).length;
  }

  setActive(String chr){
    EditFenState parent = context.findAncestorStateOfType<EditFenState>()!;
    parent.setActiveChr(chr);
  }
  clearAll(){
    EditFenState parent = context.findAncestorStateOfType<EditFenState>()!;
    parent.clearAll();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 114,
      height: widget.height,
      child: Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Wrap(
            children: allItemChrs
                .split('')
                .map<Widget>((String chr) =>
                    ItemWidget(chr: chr, count: matchCount(chr), isActive: widget.activeChr == chr,))
                .toList(),
          ),
          Wrap(
            children: allItemChrs
                .toUpperCase()
                .split('')
                .map<Widget>((String chr) =>
                    ItemWidget(chr: chr, count: matchCount(chr), isActive: widget.activeChr == chr))
                .toList(),
          ),
          Wrap(
            children: [
              ElevatedButton(onPressed: (){
                clearAll();
              }, child: Text(S.of(context).clear_all))
            ],
          )
        ],
      ),
    );
  }
}

class ItemWidget extends StatelessWidget {
  final String chr;
  final int count;
  final bool isActive;

  const ItemWidget({Key? key,required this.chr,required this.count, this.isActive = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GameWrapperState wrapper =
        context.findAncestorStateOfType<GameWrapperState>()!;
    GameManager manager = wrapper.gamer;
    _ChessBoxState parent = context.findAncestorStateOfType<_ChessBoxState>()!;
    return GestureDetector(
      onTap: (){
        if(count > 0) {
          parent.setActive(chr);
        }
      },
      child: Container(
        width: manager.skin.size * manager.scale,
        height: manager.skin.size * manager.scale,
        child: Stack(
          children: [
            Piece(
              isActive: isActive,
              item: ChessItem(chr,),
            ),
            Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                      color: count > 0 ? Colors.red : Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  child: Center(
                    child: Text(count.toString(),style: TextStyle(color: Colors.white),),
                  ),
                ))
          ],
        ),
      ),
    ) ;
  }
}
