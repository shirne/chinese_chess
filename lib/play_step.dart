

import 'package:flutter/material.dart';

import 'game.dart';
import 'models/game_manager.dart';

class PlayStep extends StatefulWidget{
  final BoxDecoration decoration;
  final double height;

  const PlayStep({Key key, this.decoration, this.height}) : super(key: key);

  @override
  State<PlayStep> createState() => PlayStepState();
}

class PlayStepState extends State<PlayStep> {
  List<String> steps = [ ];
  GameManager gamer;

  @override
  void initState() {
    super.initState();
    GameWrapperState gameWrapper = context.findAncestorStateOfType<GameWrapperState>();
    gamer = gameWrapper.gamer;
    gamer.stepNotifier.addListener(updateStep);
    steps = gamer.getSteps();
    steps.insert(0, '==开始==');
  }

  @override
  dispose(){
    gamer.stepNotifier.removeListener(updateStep);
    super.dispose();
  }

  updateStep(){
    if(gamer.stepNotifier.value == 'clear'){
      setState(() {
        steps = ['==开始=='];
      });
    }else {
      setState(() {
        gamer.stepNotifier.value.split('\n').forEach((element) {
          steps.add(gamer.stepNotifier.value);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.height,
      padding: EdgeInsets.all(10),
      decoration: widget.decoration,
      child: ListView(
        children: steps.map<Widget>((e) => Text(e)).toList(),
      ),
    );
  }
}