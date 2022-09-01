import 'package:chinese_chess/models/game_event.dart';
import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import '../models/game_manager.dart';

/// 着法列表
class PlayStep extends StatefulWidget {
  final BoxDecoration? decoration;
  final double width;

  const PlayStep({Key? key, this.decoration, required this.width})
      : super(key: key);

  @override
  State<PlayStep> createState() => PlayStepState();
}

class PlayStepState extends State<PlayStep> {
  final List<String> steps = [''];
  final ScrollController _controller = ScrollController(keepScrollOffset: true);
  final GameManager gamer = GameManager.instance;

  int currentStep = 0;

  @override
  void initState() {
    super.initState();

    gamer.on<GameStepEvent>(updateStep);
    steps.addAll(gamer.getSteps());
    currentStep = gamer.currentStep;
  }

  @override
  void dispose() {
    gamer.off<GameStepEvent>(updateStep);
    super.dispose();
  }

  void updateStep(GameEvent event) {
    String message = event.data!;
    if (message.isEmpty || !mounted) return;
    if (message == 'clear') {
      setState(() {
        currentStep = gamer.currentStep - 1;
        steps.removeRange(currentStep + 1, steps.length);
      });
    } else if (message == 'step') {
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
    Future.delayed(const Duration(milliseconds: 16)).then((value) {
      ScrollPositionWithSingleContext position =
          _controller.position as ScrollPositionWithSingleContext;
      _controller.animateTo(
        position.maxScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      padding: const EdgeInsets.all(10),
      decoration: widget.decoration,
      child: ListView.builder(
        controller: _controller,
        itemCount: steps.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () {
            if (!gamer.canBacktrace) return;
            gamer.loadHistory(index);
            setState(() {
              currentStep = index;
            });
          },
          child: Container(
            height: 23,
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: currentStep == index ? Colors.black26 : Colors.transparent,
            ),
            child: (index > 0 && index % 2 == 1)
                ? Text('${(index + 1) ~/ 2}.${steps[index]}')
                : Text(
                    '   ${index == 0 ? S.of(context).step_start : steps[index]}',
                  ),
          ),
        ),
      ),
    );
  }
}
