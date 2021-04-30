import 'package:flutter/material.dart';

import 'game.dart';
import 'models/game_manager.dart';

class PlayStep extends StatefulWidget {
  final BoxDecoration decoration;
  final double height;

  const PlayStep({Key key, this.decoration, this.height}) : super(key: key);

  @override
  State<PlayStep> createState() => PlayStepState();
}

class PlayStepState extends State<PlayStep> {
  List<String> steps = [];
  ScrollController _controller;
  GameManager gamer;

  int currentStep = 0;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController(keepScrollOffset: true);
    GameWrapperState gameWrapper =
        context.findAncestorStateOfType<GameWrapperState>();
    gamer = gameWrapper.gamer;
    gamer.stepNotifier.addListener(updateStep);
    steps = gamer.getSteps();
    steps.insert(0, '==开始==');
  }

  @override
  dispose() {
    gamer.stepNotifier.removeListener(updateStep);
    super.dispose();
  }

  updateStep() {
    if (gamer.stepNotifier.value == 'clear') {
      setState(() {
        steps = ['==开始=='];
        currentStep = 0;
      });
    } else {
      setState(() {
        gamer.stepNotifier.value.split('\n').forEach((element) {
          steps.add(gamer.stepNotifier.value);
        });
        currentStep = steps.length - 1;
      });
      Future.delayed(Duration(milliseconds: 16)).then((value) {
        _controller.animateTo(steps.length * 23.0,
            duration: Duration(milliseconds: 100), curve: Curves.easeOut);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int step = 0;
    return Container(
      width: widget.height,
      padding: EdgeInsets.all(10),
      decoration: widget.decoration,
      child: ListView(
        controller: _controller,
        children: steps.map<Widget>((e) {
          int myIndex = step;
          return GestureDetector(
            onTap: () {
              // print(myIndex);
              gamer.loadHistory(myIndex);
              setState(() {
                currentStep = myIndex;
              });
            },
            child: Container(
              height: 23,
              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
              decoration: currentStep == myIndex
                  ? BoxDecoration(color: Colors.black26)
                  : null,
              child: Row(
                children: [
                  (step++ > 0 && step % 2 == 0)
                      ? Text('${step ~/ 2}.')
                      : Text('   '),
                  Text(e)
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
