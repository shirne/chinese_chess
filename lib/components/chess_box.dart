import 'package:cchess/cchess.dart';
import 'package:flutter/material.dart';

import 'edit_fen.dart';
import 'piece.dart';
import '../global.dart';
import '../models/game_manager.dart';
import '../widgets/game_wrapper.dart';

/// 棋子盒 双方
class ChessBox extends StatefulWidget {
  final String itemChrs;
  final String activeChr;
  final double height;

  const ChessBox({
    super.key,
    required this.itemChrs,
    this.activeChr = '',
    required this.height,
  });

  @override
  State<ChessBox> createState() => _ChessBoxState();
}

class _ChessBoxState extends State<ChessBox> {
  static const allItemChrs = 'kabcnrp';

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
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 114,
      height: widget.height,
      child: Flex(
        direction: Axis.vertical,
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
            children: allItemChrs
                .toUpperCase()
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
                child: Text(
                  context.l10n.clearAll,
                ),
              ),
            ],
          ),
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
    super.key,
    required this.chr,
    required this.count,
    this.isActive = false,
  });

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
            ),
          ],
        ),
      ),
    );
  }
}
