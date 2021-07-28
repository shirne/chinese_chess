



import 'package:flutter/material.dart';

import 'widgets/game_wrapper.dart';
import 'models/game_manager.dart';

class PlayBot extends StatefulWidget{

  const PlayBot({Key? key}) : super(key: key);

  @override
  State<PlayBot> createState() => PlayStepState();
}

class PlayStepState extends State<PlayBot> {
  List<String> botMessages = [ ];
  late ScrollController _controller;
  late GameManager gamer;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController(keepScrollOffset: true);
    GameWrapperState gameWrapper = context.findAncestorStateOfType<GameWrapperState>()!;
    gamer = gameWrapper.gamer;
    gamer.messageNotifier.addListener(updateMessage);
  }

  @override
  dispose(){
    gamer.messageNotifier.removeListener(updateMessage);
    super.dispose();
  }

  updateMessage(){
    if(gamer.messageNotifier.value.isEmpty)return;
    if(gamer.messageNotifier.value == 'clear'){
      setState(() {
        botMessages = [];
      });
    }else {
      setState(() {
        botMessages.add(gamer.messageNotifier.value);
      });
    }
    Future.delayed(Duration(milliseconds: 16)).then((value) {
      ScrollPositionWithSingleContext position  = _controller.position as ScrollPositionWithSingleContext;
      _controller.animateTo(position.maxScrollExtent,
          duration: Duration(milliseconds: 100), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        controller: _controller,
        padding: EdgeInsets.all(10),
        children: botMessages.map<Widget>((e) => Text(e)).toList(),
      ),
    );
  }
}