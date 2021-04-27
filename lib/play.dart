import 'package:chinese_chess/play_player.dart';
import 'package:chinese_chess/play_step.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'chess.dart';
import 'game.dart';
import 'models/game_manager.dart';
import 'play_bot.dart';
import 'widgets/tab_card.dart';

class PlayPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PlayPageState();
}

class PlayPageState extends State<PlayPage> {
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

    BoxDecoration decoration = BoxDecoration(border: Border.all(color: Colors.grey, width: 0.5),borderRadius: BorderRadius.all(Radius.circular(2)));
    return Container(
      width: 981,
      height: 600,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: 521,
            child: Chess(),
          ),
          Container(
            width: 420,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(2)),
              boxShadow: [BoxShadow(
                color: Color.fromRGBO(0, 0, 0, .1),
                offset: Offset(1, 1),
                blurRadius: 1.0,
                spreadRadius: 1.0
              )]
            ),
            child: Column(
              mainAxisSize:MainAxisSize.max,
              children: [
                Container(
                  height: 200,
                  decoration: decoration,
                  child: TabCard(
                      titlePadding:EdgeInsets.symmetric( vertical: 10, horizontal: 30),
                      titles:[
                        Text('当前信息'),
                        Text('棋局信息')
                      ],
                      bodies:[
                        Center(child:Text('暂无信息')),
                        Center(child:Text('暂无棋局信息'))
                      ]
                  ),
                ),
                SizedBox(height: 10,),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PlayPlayer(height: 200,),
                      PlayStep(decoration:decoration,height: 200,),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  height: 200,
                  decoration: decoration,
                  child: TabCard(
                      titlePadding:EdgeInsets.symmetric( vertical: 10, horizontal: 30),
                    titles:[
                      Text('推荐招法'),
                      Text('注解')
                    ],
                    bodies:[
                      PlayBot(),
                      Center(
                          child:Text('暂无注解'),
                      )
                    ]
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
