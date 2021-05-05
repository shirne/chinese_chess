import 'dart:async';
import 'package:chinese_chess/generated/l10n.dart';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/game_manager.dart';

class GameWrapper extends StatefulWidget {
  final Widget child;
  final bool isMain;

  const GameWrapper({Key key, this.child, this.isMain = false}) : super(key: key);

  static GameWrapperState of(BuildContext context) {
    return context.findAncestorStateOfType<GameWrapperState>();
  }

  @override
  State<GameWrapper> createState() => GameWrapperState();
}

class GameWrapperState extends State<GameWrapper> {
  GameManager gamer;
  bool inited = false;

  @override
  void initState() {
    super.initState();
    if (gamer != null) {
      print('gamer inited');
      gamer.dispose();
    }

      onInit();

  }

  void onInit() async{
    if(widget.isMain){
      await Future.delayed(Duration(milliseconds: 500));
    }
    gamer = GameManager();
    await gamer.init();
    if(widget.isMain){
      await Future.delayed(Duration(milliseconds: 500));
    }
    setState(() {
      inited = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        print('onwillpop');
        Completer<bool> completer = Completer<bool>();
        if(widget.isMain) {
          MyDialog.of(context)
              .confirm(S.of(context).exit_now, buttonText: S.of(context).yes_exit, cancelText: S.of(context).dont_exit)
              .then((sure) {
            if (sure) {
              print('gamer destroy');
              gamer.dispose();
              gamer = null;
              Future.delayed(Duration(milliseconds: 500)).then((v){
                completer.complete(true);
              });
            }else{
              completer.complete(false);
            }
          });
        }else{
          Future.delayed(Duration(milliseconds: 1)).then((v){
            completer.complete(true);
          });
        }
        return completer.future;
      },
      child: inited ? widget.child :Scaffold(body: Center(child: CircularProgressIndicator()),) ,
    );
  }

  @override
  void dispose() {
    print('gamer destroy');
    gamer.dispose();
    gamer = null;
    super.dispose();
  }
}
