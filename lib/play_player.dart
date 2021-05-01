




import 'package:flutter/material.dart';

import 'game.dart';
import 'models/game_manager.dart';
import 'widgets/tab_card.dart';

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
    BoxDecoration decoration = BoxDecoration(
        border: Border.all(color: Colors.grey, width: 0.5),
        borderRadius: BorderRadius.all(Radius.circular(2)));
    return Container(
      width: 209,
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('黑方'),
          ),
          SizedBox(
            width: 10,
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('红方'),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Container(
              decoration: decoration,
              child: TabCard(
                  titlePadding: EdgeInsets.only(top: 10,bottom: 10),
                  titles: [
                    Text('当前信息'),
                    Text('棋局信息')
                  ],
                  bodies: [
                    Center(child: Text('暂无信息')),
                    Center(child: Text('暂无棋局信息'))
                  ]),
            ),
          )
        ],
      ),
    );
  }
}