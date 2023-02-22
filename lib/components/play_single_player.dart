import 'package:flutter/material.dart';

import '../global.dart';
import '../driver/player_driver.dart';
import '../models/game_event.dart';
import '../models/game_manager.dart';
import '../widgets/list_item.dart';

/// 单个玩家框
class PlaySinglePlayer extends StatefulWidget {
  final int team;
  final Alignment placeAt;

  const PlaySinglePlayer({
    Key? key,
    required this.team,
    this.placeAt = Alignment.topCenter,
  }) : super(key: key);

  @override
  State<PlaySinglePlayer> createState() => PlaySinglePlayerState();
}

class PlaySinglePlayerState extends State<PlaySinglePlayer> {
  late GameManager gamer = GameManager.instance;
  int currentTeam = 0;

  @override
  void initState() {
    super.initState();

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
        tooltip: context.l10n.trusteeship_to_robots,
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
        tooltip: context.l10n.cancel_robots,
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
    Widget leading;
    Widget trailing;
    TextDirection tDirect;
    if (widget.placeAt == Alignment.topCenter) {
      leading = Icon(
        Icons.person,
        size: 28,
        color: currentTeam == widget.team ? Colors.blueAccent : Colors.black12,
      );
      trailing = switchRobot(widget.team);
      tDirect = TextDirection.ltr;
    } else {
      trailing = Icon(
        Icons.person,
        size: 28,
        color: currentTeam == widget.team ? Colors.blueAccent : Colors.black12,
      );
      leading = switchRobot(widget.team);
      tDirect = TextDirection.rtl;
    }
    List<Widget> childs = [
      SizedBox(
        width: 229,
        child: ListItem(
          leading: leading,
          title: Text(
            gamer.getPlayer(widget.team).title,
            style: const TextStyle(fontSize: 14),
            textDirection: tDirect,
          ),
          subtitle: currentTeam == widget.team
              ? Text(
                  context.l10n.thinking,
                  style: const TextStyle(fontSize: 10),
                  textDirection: tDirect,
                )
              : null,
          trailing: trailing,
          titleAlign: widget.placeAt == Alignment.topCenter
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
        ),
      ),
      const SizedBox(width: 10),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: widget.placeAt == Alignment.topCenter
            ? childs
            : childs.reversed.toList(),
      ),
    );
  }
}
