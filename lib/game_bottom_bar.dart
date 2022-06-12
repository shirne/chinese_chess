import 'package:flutter/material.dart';

import 'models/play_mode.dart';

class GameBottomBar extends StatefulWidget {
  final PlayMode mode;

  const GameBottomBar(this.mode, {Key? key}) : super(key: key);

  @override
  State<GameBottomBar> createState() => GameBottomBarState();
}

class GameBottomBarState extends State<GameBottomBar> {
  @override
  Widget build(BuildContext context) {
    if (widget.mode == PlayMode.modeRobot) {
      return robotBottomBar();
    }
    if (widget.mode == PlayMode.modeRobot) {
      return onlineBottomBar();
    }

    return freeBottomBar();
  }

  Widget freeBottomBar() {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(icon: Icon(Icons.list), onPressed: () {}),
          IconButton(icon: Icon(Icons.code), onPressed: () {}),
          IconButton(icon: Icon(Icons.navigate_before), onPressed: () {}),
          IconButton(icon: Icon(Icons.navigate_next), onPressed: () {})
        ],
      ),
    );
  }

  Widget onlineBottomBar() {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(icon: Icon(Icons.list), onPressed: () {}),
          IconButton(icon: Icon(Icons.replay), onPressed: () {}),
          IconButton(icon: Icon(Icons.navigate_before), onPressed: () {}),
          IconButton(icon: Icon(Icons.navigate_next), onPressed: () {})
        ],
      ),
    );
  }

  Widget robotBottomBar() {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(icon: Icon(Icons.list), onPressed: () {}),
          IconButton(icon: Icon(Icons.replay), onPressed: () {}),
          IconButton(icon: Icon(Icons.navigate_before), onPressed: () {}),
          IconButton(icon: Icon(Icons.navigate_next), onPressed: () {})
        ],
      ),
    );
  }
}
