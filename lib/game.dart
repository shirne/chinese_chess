


import 'package:flutter/material.dart';

import 'models/Gamer.dart';
import 'play.dart';

class GameWrapper extends StatefulWidget{
  @override
  State<GameWrapper> createState() => GameWrapperState();

}

class GameWrapperState extends State<GameWrapper> {
  Gamer gamer;
  @override
  void initState() {
    super.initState();
    if(gamer != null){
      print('gamer inited');
      gamer.destroy();
    }
    gamer = Gamer();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:PlayPage()
    );
  }

  @override
  void dispose() {
    super.dispose();
    print('gamer destroy');
    gamer.destroy();
    gamer = null;
  }
}