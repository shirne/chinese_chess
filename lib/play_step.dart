import 'package:flutter/material.dart';

import 'generated/l10n.dart';
import 'widgets/game_wrapper.dart';
import 'models/game_manager.dart';

class PlayStep extends StatefulWidget {
  final BoxDecoration? decoration;
  final double width;

  const PlayStep({Key? key, this.decoration,required this.width}) : super(key: key);

  @override
  State<PlayStep> createState() => PlayStepState();
}

class PlayStepState extends State<PlayStep> {
  List<String> steps = [];
  late ScrollController _controller;
  late GameManager gamer;

  int currentStep = 0;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController(keepScrollOffset: true);
    GameWrapperState gameWrapper =
    context.findAncestorStateOfType<GameWrapperState>()!;
    gamer = gameWrapper.gamer;
    gamer.stepNotifier.addListener(updateStep);
    steps = gamer.getSteps();
  }

  @override
  dispose() {
    gamer.stepNotifier.removeListener(updateStep);
    super.dispose();
  }

  updateStep() {
    String message = gamer.stepNotifier.value;
    if (message == 'clear') {
      setState(() {
        currentStep = gamer.currentStep;
        if (gamer.currentStep == 0) {
          steps = [S.of(context).step_start];
        } else {
          steps.removeRange(currentStep + 1, steps.length);
        }
      });
    }else if(message == 'step'){
      setState(() {
        currentStep = gamer.currentStep;
      });
    } else {
      setState(() {
        message.split('\n').forEach((element) {
          steps.add(element);
        });
        currentStep = steps.length - 1;
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
    if(steps.length < 1){
      steps.insert(0, S.of(context).step_start);
    }
    int step = 0;
    return Container(
      width: widget.width,
      padding: EdgeInsets.all(10),
      decoration: widget.decoration,
      child: ListView(
        controller: _controller,
        children: steps.map<Widget>((e) {
          int myIndex = step;
          return GestureDetector(
            onTap: () {
              if(!gamer.canBacktrace)return;
              gamer.loadHistory(myIndex);
              setState(() {
                currentStep = myIndex;
              });
            },
            child: Container(
              height: 23,
              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
              decoration:
                BoxDecoration(
                    color: currentStep == myIndex ?
                      Colors.black26 : Colors.transparent,
                ),
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
