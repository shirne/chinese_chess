import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'driver/player_driver.dart';
import 'generated/l10n.dart';
import 'widgets/game_wrapper.dart';
import 'models/game_manager.dart';
import 'widgets/list_item.dart';
import 'widgets/tab_card.dart';

class PlaySinglePlayer extends StatefulWidget {
  final int team;
  final Alignment placeAt;

  const PlaySinglePlayer({Key key, this.team, this.placeAt = Alignment.topCenter}) : super(key: key);

  @override
  State<PlaySinglePlayer> createState() => PlaySinglePlayerState();
}

class PlaySinglePlayerState extends State<PlaySinglePlayer> {
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
        tooltip: S.of(context).trusteeship_to_robots,
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
        tooltip: S.of(context).cancel_robots,
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
    Widget leading;
    Widget trailing;
    TextDirection tDirect;
    if(widget.placeAt == Alignment.topCenter){
      leading = Icon(
        Icons.person,
        size: 28,
        color: currentTeam == widget.team ? Colors.blueAccent : Colors.black12,
      );
      trailing = switchRobot(widget.team);
      tDirect = TextDirection.ltr;
    }else{
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
          title: Text(gamer.getPlayer(widget.team).title, style: TextStyle(fontSize: 14), textDirection: tDirect,),
          subtitle: currentTeam == widget.team ? Text( S.of(context).thinking , style: TextStyle(fontSize: 10), textDirection: tDirect) : null,
          trailing: trailing,
          titleAlign: widget.placeAt == Alignment.topCenter ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        ),
      ),
      SizedBox(
        width: 10,
      ),
    ];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: widget.placeAt == Alignment.topCenter ? childs : childs.reversed.toList(),
      ),
    );
  }
}
