import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'driver/player_driver.dart';
import 'widgets/game_wrapper.dart';
import 'models/game_manager.dart';
import 'widgets/tab_card.dart';

class PlayPlayer extends StatefulWidget {
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
    GameWrapperState gameWrapper =
        context.findAncestorStateOfType<GameWrapperState>();
    gamer = gameWrapper.gamer;
    gamer.playerNotifier.addListener(onChangePlayer);
    gamer.gameNotifier.addListener(onReloadGame);
    gamer.resultNotifier.addListener(onResult);
  }

  @override
  dispose() {
    gamer.playerNotifier.removeListener(onChangePlayer);
    gamer.gameNotifier.removeListener(onReloadGame);
    gamer.resultNotifier.removeListener(onResult);
    super.dispose();
  }

  onResult() {
    setState(() {});
  }

  onReloadGame() {
    if (gamer.gameNotifier.value != 0) return;
    setState(() {});
  }

  onChangePlayer() {
    setState(() {
      currentTeam = gamer.playerNotifier.value;
    });
  }

  Widget switchRobot(int team) {
    if (gamer.hands[team].isUser) {
      return IconButton(
        icon: Icon(Icons.android),
        tooltip: '托管给机器人',
        onPressed: () {
          changePlayDriver(team, DriverType.robot);
        },
      );
    } else if (gamer.hands[team].isRobot) {
      return IconButton(
        icon: Icon(
          Icons.android,
          color: Colors.blueAccent,
        ),
        tooltip: '取消托管',
        onPressed: () {
          changePlayDriver(team, DriverType.user);
        },
      );
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
      width: 229,
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.person,
              color: currentTeam == 1 ? Colors.blueAccent : Colors.black12,
            ),
            title: Text(gamer.getPlayer(1).title),
            subtitle: Text(currentTeam == 1 ? '思考中...' : ''),
            trailing: switchRobot(1),
          ),
          SizedBox(
            width: 10,
          ),
          ListTile(
            leading: Icon(Icons.person,
                color: currentTeam == 0 ? Colors.blueAccent : Colors.black12),
            title: Text(gamer.getPlayer(0).title),
            subtitle: Text(currentTeam == 0 ? '思考中...' : ''),
            trailing: switchRobot(0),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Container(
              decoration: decoration,
              child: TabCard(
                  titlePadding: EdgeInsets.only(top: 10, bottom: 10),
                  titles: [
                    Text('当前信息'),
                    Text('棋局信息')
                  ],
                  bodies: [
                    Center(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(gamer.manual.event),
                            Text(
                                '${gamer.manual.red} (${gamer.manual.chineseResult}) ${gamer.manual.black}'),
                            Text(gamer.manual.ecco.isEmpty
                                ? ''
                                : '${gamer.manual.opening}(${gamer.manual.ecco})'),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Table(
                        border: null,
                        columnWidths: {
                          0: IntrinsicColumnWidth(),
                          1: FlexColumnWidth(),
                        },
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.top,
                        children: [
                          TableRow(children: [
                            Text('赛事：'),
                            Text(gamer.manual.event)
                          ]),
                          TableRow(
                              children: [Text('地点：'), Text(gamer.manual.site)]),
                          TableRow(
                              children: [Text('日期：'), Text(gamer.manual.date)]),
                          TableRow(children: [
                            Text('轮次：'),
                            Text(gamer.manual.round)
                          ]),
                          TableRow(children: [
                            Text('红方：'),
                            Text('${gamer.manual.redTeam}/${gamer.manual.red}'),
                          ]),
                          TableRow(children: [
                            Text('黑方：'),
                            Text(
                                '${gamer.manual.blackTeam}/${gamer.manual.black}'),
                          ]),
                        ],
                      ),
                    )
                  ]),
            ),
          )
        ],
      ),
    );
  }
}
