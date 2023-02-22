import 'package:cchess/cchess.dart';
import 'package:flutter/material.dart';

import 'edit_fen.dart';
import 'piece.dart';
import '../global.dart';
import '../models/game_manager.dart';
import '../widgets/game_wrapper.dart';

/// 棋子盒 单方
class ChessSingleBox extends StatefulWidget {
  final String itemChrs;
  final String activeChr;
  final double width;
  final int team;

  const ChessSingleBox({
    Key? key,
    required this.itemChrs,
    this.activeChr = '',
    required this.width,
    this.team = 0,
  }) : super(key: key);

  @override
  State<ChessSingleBox> createState() => _ChessBoxState();
}

class _ChessBoxState extends State<ChessSingleBox> {
  static String allItemChrs = 'kabcnrp';
  GameManager? gamer;

  int matchCount(String chr) {
    return RegExp(chr).allMatches(widget.itemChrs).length;
  }

  void setActive(String chr) {
    EditFenState parent = context.findAncestorStateOfType<EditFenState>()!;
    parent.setActiveChr(chr);
  }

  void clearAll() {
    EditFenState parent = context.findAncestorStateOfType<EditFenState>()!;
    parent.clearAll();
  }

  @override
  void initState() {
    super.initState();
    if (widget.team == 0) {
      allItemChrs = allItemChrs.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (gamer == null) {
      GameWrapperState gameWrapper =
          context.findAncestorStateOfType<GameWrapperState>()!;
      gamer = gameWrapper.gamer;
    }
    return SizedBox(
      width: widget.width,
      height: gamer!.skin.size * gamer!.scale,
      child: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Wrap(
            children: allItemChrs
                .split('')
                .map<Widget>(
                  (String chr) => ItemWidget(
                    chr: chr,
                    count: matchCount(chr),
                    isActive: widget.activeChr == chr,
                  ),
                )
                .toList(),
          ),
          Wrap(
            children: [
              ElevatedButton(
                onPressed: () {
                  clearAll();
                },
                child: Text(context.l10n.clearAll),
              )
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

  const ItemWidget({
    Key? key,
    required this.chr,
    required this.count,
    this.isActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GameWrapperState wrapper =
        context.findAncestorStateOfType<GameWrapperState>()!;
    GameManager manager = wrapper.gamer;
    _ChessBoxState parent = context.findAncestorStateOfType<_ChessBoxState>()!;
    return GestureDetector(
      onTap: () {
        if (count > 0) {
          parent.setActive(chr);
        }
      },
      child: SizedBox(
        width: manager.skin.size * manager.scale,
        height: manager.skin.size * manager.scale,
        child: Stack(
          children: [
            Piece(
              isActive: isActive,
              item: ChessItem(
                chr,
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: count > 0 ? Colors.red : Colors.grey,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Center(
                  child: Text(
                    count.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
