




import 'package:flutter/material.dart';

import 'driver/player_driver.dart';
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
  int currentTeam = 0;

  @override
  void initState() {
    super.initState();
    GameWrapperState gameWrapper = context.findAncestorStateOfType<GameWrapperState>();
    gamer = gameWrapper.gamer;
    gamer.playerNotifier.addListener(onChangePlayer);
  }

  @override
  dispose(){
    gamer.playerNotifier.removeListener(onChangePlayer);
    super.dispose();
  }
  onChangePlayer(){
    setState(() {
      currentTeam = gamer.playerNotifier.value;
    });
  }

  Widget switchRobot(int team){
    if(gamer.hands[team].isUser){
      return IconButton(
        icon: Icon(Icons.android),
        tooltip: '托管给机器人',
        onPressed: () {
          changePlayDriver(team, DriverType.robot);
        },);
    }else if(gamer.hands[team].isRobot) {
      return IconButton(
        icon: Icon(Icons.android, color: Colors.blueAccent,),
        tooltip: '取消托管',
        onPressed: () {
          changePlayDriver(team, DriverType.user);
        },);
    }
    return null;
  }

  void changePlayDriver(int team, DriverType driverType) {
    setState(() {
      gamer.switchDriver(team, driverType);
    });
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
            leading: Icon(Icons.person, color: currentTeam == 1 ? Colors.blueAccent : Colors.black12,),
            title: Text('黑方'),
            subtitle: Text(currentTeam == 1?'思考中...':''),
            trailing: switchRobot(1),
          ),
          SizedBox(
            width: 10,
          ),
          ListTile(
            leading: Icon(Icons.person, color: currentTeam == 0 ? Colors.blueAccent : Colors.black12),
            title: Text('红方'),
            subtitle: Text(currentTeam == 0?'思考中...':''),
            trailing: switchRobot(0),
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