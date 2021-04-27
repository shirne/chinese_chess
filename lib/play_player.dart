




import 'package:flutter/material.dart';

import 'game.dart';
import 'models/game_manager.dart';

class PlayPlayer extends StatefulWidget{
  final double height;

  const PlayPlayer({Key key, this.height}) : super(key: key);

  @override
  State<PlayPlayer> createState() => PlayStepState();
}

class PlayStepState extends State<PlayPlayer> {
  GameManager gamer;

  @override
  void initState() {
    super.initState();
    GameWrapperState gameWrapper = context.findAncestorStateOfType<GameWrapperState>();
    gamer = gameWrapper.gamer;
  }

  @override
  dispose(){
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('黑方'),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('红方'),
          ),
        ],
      ),
    );
  }
}