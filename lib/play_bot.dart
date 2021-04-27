



import 'package:flutter/material.dart';

import 'game.dart';
import 'models/game_manager.dart';

class PlayBot extends StatefulWidget{

  const PlayBot({Key key}) : super(key: key);

  @override
  State<PlayBot> createState() => PlayStepState();
}

class PlayStepState extends State<PlayBot> {
  List<String> botMessages = [ ];
  GameManager gamer;

  @override
  void initState() {
    super.initState();
    GameWrapperState gameWrapper = context.findAncestorStateOfType<GameWrapperState>();
    gamer = gameWrapper.gamer;
    gamer.messageNotifier.addListener(updateMessage);
  }

  @override
  dispose(){
    gamer.messageNotifier.removeListener(updateMessage);
    super.dispose();
  }

  updateMessage(){
    if(gamer.messageNotifier.value == 'clear'){
      setState(() {
        botMessages = [];
      });
    }else {
      setState(() {
        botMessages.add(gamer.messageNotifier.value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        padding: EdgeInsets.all(10),
        children: botMessages.map<Widget>((e) => Text(e)).toList(),
      ),
    );
  }
}