import 'package:flutter/material.dart';

import 'chess.dart';
import 'play_step.dart';
import 'play_single_player.dart';
import 'play_bot.dart';
import 'play_player.dart';
import '../global.dart';
import '../widgets/tab_card.dart';
import '../models/game_manager.dart';
import '../models/play_mode.dart';
import '../driver/player_driver.dart';

/// 游戏布局框
class PlayPage extends StatefulWidget {
  final PlayMode mode;

  const PlayPage({Key? key, required this.mode}) : super(key: key);
  @override
  State<StatefulWidget> createState() => PlayPageState();
}

class PlayPageState extends State<PlayPage> {
  final GameManager gamer = GameManager.instance;
  bool inited = false;

  @override
  void initState() {
    super.initState();
  }

  void initGame() async {
    if (inited) return;
    inited = true;
    gamer.newGame();
    if (widget.mode == PlayMode.modeRobot) {
      gamer.switchDriver(1, DriverType.robot);
    }
    gamer.next();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    initGame();
    return MediaQuery.of(context).size.width < 980
        ? _mobileContainer()
        : _windowContainer();
  }

  Widget _mobileContainer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const PlaySinglePlayer(
          team: 1,
        ),
        SizedBox(
          width: gamer.skin.width * gamer.scale,
          height: gamer.skin.height * gamer.scale,
          child: const Chess(),
        ),
        const PlaySinglePlayer(
          team: 0,
          placeAt: Alignment.bottomCenter,
        ),
      ],
    );
  }

  Widget _windowContainer() {
    BoxDecoration decoration = BoxDecoration(
      border: Border.all(color: Colors.grey, width: 0.5),
      borderRadius: const BorderRadius.all(Radius.circular(2)),
    );
    return SizedBox(
      width: 980,
      height: 577,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(
            width: 521,
            child: Chess(),
          ),
          Container(
            width: 439,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(2)),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, .1),
                  offset: Offset(1, 1),
                  blurRadius: 1.0,
                  spreadRadius: 1.0,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const PlayPlayer(),
                      const SizedBox(width: 10),
                      PlayStep(
                        decoration: decoration,
                        width: 180,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 180,
                  decoration: decoration,
                  child: TabCard(
                    titleFit: FlexFit.tight,
                    titlePadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 30,
                    ),
                    titles: [
                      Text(context.l10n.recommend_move),
                      Text(context.l10n.remark)
                    ],
                    bodies: [
                      const PlayBot(),
                      Center(
                        child: Text(context.l10n.no_remark),
                      )
                    ],
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
