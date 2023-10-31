import 'package:flutter/material.dart';

import '../global.dart';
import '../driver/player_driver.dart';
import '../models/game_event.dart';
import '../widgets/game_wrapper.dart';
import '../models/game_manager.dart';
import '../widgets/tab_card.dart';

/// 组合玩家框及对局双方信息框
class PlayPlayer extends StatefulWidget {
  const PlayPlayer({super.key});

  @override
  State<PlayPlayer> createState() => PlayPlayerState();
}

class PlayPlayerState extends State<PlayPlayer> {
  late GameManager gamer = GameManager.instance;
  int currentTeam = 0;

  @override
  void initState() {
    super.initState();
    GameWrapperState gameWrapper =
        context.findAncestorStateOfType<GameWrapperState>()!;
    gamer = gameWrapper.gamer;
    gamer.on<GamePlayerEvent>(onChangePlayer);
    gamer.on<GameLoadEvent>(onReloadGame);
    gamer.on<GameResultEvent>(onResult);
  }

  @override
  void dispose() {
    gamer.off<GamePlayerEvent>(onChangePlayer);
    gamer.off<GameLoadEvent>(onReloadGame);
    gamer.off<GameResultEvent>(onResult);
    super.dispose();
  }

  void onResult(GameEvent event) {
    setState(() {});
  }

  void onReloadGame(GameEvent event) {
    if (event.data != 0) return;
    setState(() {});
  }

  void onChangePlayer(GameEvent event) {
    setState(() {
      currentTeam = event.data;
    });
  }

  Widget switchRobot(int team) {
    if (gamer.hands[team].isUser) {
      return IconButton(
        icon: const Icon(Icons.android),
        tooltip: context.l10n.trusteeshipToRobots,
        onPressed: () {
          changePlayDriver(team, DriverType.robot);
        },
      );
    } else if (gamer.hands[team].isRobot) {
      return IconButton(
        icon: const Icon(
          Icons.android,
          color: Colors.blueAccent,
        ),
        tooltip: context.l10n.cancelRobots,
        onPressed: () {
          changePlayDriver(team, DriverType.user);
        },
      );
    }

    return const SizedBox();
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
      borderRadius: const BorderRadius.all(Radius.circular(2)),
    );
    return SizedBox(
      width: 229,
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.person,
              color: currentTeam == 1 ? Colors.blueAccent : Colors.black12,
            ),
            title: Text(gamer.getPlayer(1).title),
            subtitle: Text(currentTeam == 1 ? context.l10n.thinking : ''),
            trailing: switchRobot(1),
          ),
          const SizedBox(width: 10),
          ListTile(
            leading: Icon(
              Icons.person,
              color: currentTeam == 0 ? Colors.blueAccent : Colors.black12,
            ),
            title: Text(gamer.getPlayer(0).title),
            subtitle: Text(currentTeam == 0 ? context.l10n.thinking : ''),
            trailing: switchRobot(0),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              decoration: decoration,
              child: TabCard(
                titlePadding: const EdgeInsets.only(top: 10, bottom: 10),
                titles: [
                  Text(context.l10n.currentInfo),
                  Text(context.l10n.manual),
                ],
                bodies: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(gamer.manual.event),
                        Text(
                          '${gamer.manual.red} (${gamer.manual.chineseResult}) ${gamer.manual.black}',
                        ),
                        Text(
                          gamer.manual.ecco.isEmpty
                              ? ''
                              : '${gamer.manual.opening}(${gamer.manual.ecco})',
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Table(
                      border: null,
                      columnWidths: const {
                        0: IntrinsicColumnWidth(),
                        1: FlexColumnWidth(),
                      },
                      defaultVerticalAlignment: TableCellVerticalAlignment.top,
                      children: [
                        TableRow(
                          children: [
                            Text(context.l10n.theEvent),
                            Text(gamer.manual.event),
                          ],
                        ),
                        TableRow(
                          children: [
                            Text(context.l10n.theSite),
                            Text(gamer.manual.site),
                          ],
                        ),
                        TableRow(
                          children: [
                            Text(context.l10n.theDate),
                            Text(gamer.manual.date),
                          ],
                        ),
                        TableRow(
                          children: [
                            Text(context.l10n.theRound),
                            Text(gamer.manual.round),
                          ],
                        ),
                        TableRow(
                          children: [
                            Text(context.l10n.theRed),
                            Text(
                              '${gamer.manual.redTeam}/${gamer.manual.red}',
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Text(context.l10n.theBlack),
                            Text(
                              '${gamer.manual.blackTeam}/${gamer.manual.black}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
