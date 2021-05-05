
import 'package:chinese_chess/driver/player_driver.dart';
import 'package:chinese_chess/play_step.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'chess.dart';
import 'generated/l10n.dart';
import 'models/play_mode.dart';
import 'widgets/game_wrapper.dart';
import 'models/game_manager.dart';
import 'play_bot.dart';
import 'play_player.dart';
import 'widgets/tab_card.dart';

class PlayPage extends StatefulWidget {
  final PlayMode mode;

  const PlayPage({Key key, this.mode}) : super(key: key);
  @override
  State<StatefulWidget> createState() => PlayPageState();
}

class PlayPageState extends State<PlayPage> {
  GameManager gamer;
  bool inited = false;

  @override
  void initState() {
    super.initState();
    GameWrapperState gameWrapper =
        context.findAncestorStateOfType<GameWrapperState>();
    gamer = gameWrapper.gamer;
  }

  initGame() async{
    if(inited)return;
    inited=true;
    gamer.newGame();
    if(widget.mode == PlayMode.modeRobot){
      gamer.switchDriver(1, DriverType.robot);
    }
    gamer.next();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    initGame();
    BoxDecoration decoration = BoxDecoration(
        border: Border.all(color: Colors.grey, width: 0.5),
        borderRadius: BorderRadius.all(Radius.circular(2)));
    return Container(
      width: 980,
      height: 577,
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
            width: 439,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(2)),
                boxShadow: [
                  BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, .1),
                      offset: Offset(1, 1),
                      blurRadius: 1.0,
                      spreadRadius: 1.0)
                ]),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PlayPlayer(),
                      SizedBox(
                        width: 10,
                      ),
                      PlayStep(
                        decoration: decoration,
                        width: 180,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: 180,
                  decoration: decoration,
                  child: TabCard(
                    titleFit: FlexFit.tight,
                      titlePadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                      titles: [
                        Text(S.of(context).recommend_move),
                        Text(S.of(context).remark)
                      ],
                      bodies: [
                        PlayBot(),
                        Center(
                          child: Text(S.of(context).no_remark),
                        )
                      ]),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
