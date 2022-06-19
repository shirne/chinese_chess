import 'package:flutter/material.dart';

import '../models/game_event.dart';
import '../widgets/game_wrapper.dart';
import '../models/game_manager.dart';

/// 引擎提示框
class PlayBot extends StatefulWidget {
  const PlayBot({Key? key}) : super(key: key);

  @override
  State<PlayBot> createState() => PlayStepState();
}

class PlayStepState extends State<PlayBot> {
  List<String> botMessages = [];
  late ScrollController _controller;
  late GameManager gamer = GameManager.instance;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController(keepScrollOffset: true);

    gamer.on<GameEngineEvent>(updateMessage);
  }

  @override
  dispose() {
    gamer.off<GameEngineEvent>(updateMessage);
    super.dispose();
  }

  void updateMessage(GameEvent event) {
    if (event.data == null || event.data.isEmpty) return;
    if (event.data == 'clear') {
      setState(() {
        botMessages = [];
      });
    } else {
      setState(() {
        botMessages.add(event.data);
      });
    }
    Future.delayed(const Duration(milliseconds: 16)).then((value) {
      ScrollPositionWithSingleContext position =
          _controller.position as ScrollPositionWithSingleContext;
      _controller.animateTo(position.maxScrollExtent,
          duration: const Duration(milliseconds: 100), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _controller,
      padding: const EdgeInsets.all(10),
      children: botMessages.map<Widget>((e) => Text(e)).toList(),
    );
  }
}
