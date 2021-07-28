import 'dart:async';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import '../models/game_manager.dart';

class GameWrapper extends StatefulWidget {
  final Widget child;
  final bool isMain;

  const GameWrapper({Key? key,required this.child, this.isMain = false})
      : super(key: key);

  static GameWrapperState of(BuildContext context) {
    return context.findAncestorStateOfType<GameWrapperState>()!;
  }

  @override
  State<GameWrapper> createState() => GameWrapperState();
}

class GameWrapperState extends State<GameWrapper> {
  late GameManager gamer;
  bool inited = false;

  @override
  void initState() {
    super.initState();

    onInit();
  }

  void onInit() async {
    if (widget.isMain) {
      await Future.delayed(Duration(milliseconds: 500));
    }
    gamer = GameManager();
    await gamer.init();
    if (widget.isMain) {
      await Future.delayed(Duration(milliseconds: 500));
    }
    setState(() {
      inited = true;
    });
  }

  Future<bool> _willPop() async {
    print('onwillpop');
    final sure = await MyDialog.of(context).confirm(S.of(context).exit_now,
        buttonText: S.of(context).yes_exit,
        cancelText: S.of(context).dont_exit);

    if (sure ?? false) {
      print('gamer destroy');
      gamer.dispose();
      //gamer = null;
      await Future.delayed(Duration(milliseconds: 200));
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (inited) {
      Size size = MediaQuery.of(context).size;
      if (size.width < 541) {
        gamer.scale = (size.width - 20) / 521;
      } else {
        gamer.scale = 1;
      }
    }
    return WillPopScope(
      onWillPop: widget.isMain ? _willPop : null,
      child: inited
          ? widget.child
          : Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
    );
  }

  @override
  void dispose() {
    print('gamer destroy');
    gamer.dispose();
    //gamer = null;
    super.dispose();
  }
}
