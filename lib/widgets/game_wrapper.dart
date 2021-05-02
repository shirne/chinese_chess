import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/game_manager.dart';
import 'customer_dialog.dart';

class GameWrapper extends StatefulWidget {
  final Widget child;

  const GameWrapper({Key key, this.child}) : super(key: key);

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
    gamer = GameManager();
    gamer.init().then((val) {
      setState(() {
        inited = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Completer<bool> complete = Completer<bool>();
        CustomerDialog.of(context)
            .confirm('确定退出游戏？', buttonText: '退出', cancelText: '再想想')
            .then((bool sure) {
          if (sure) {
            print('gamer destroy');
            gamer.dispose();
            gamer = null;
            complete.complete(true);
          }
        });

        return complete.future;
      },
      child: inited ? widget.child : Center(child: CircularProgressIndicator()),
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
