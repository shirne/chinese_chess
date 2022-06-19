import 'dart:async';

import 'package:flutter/material.dart';

enum ActionType {
  eat,
  checkMate,
  kill,
}

class ActionDialog extends StatefulWidget {
  final ActionType type;
  const ActionDialog(this.type, {Key? key}) : super(key: key);

  @override
  State<ActionDialog> createState() => _ActionDialogState();
}

String assets(ActionType type) {
  switch (type) {
    case ActionType.eat:
      return 'assets/images/action_eat.png';
    case ActionType.checkMate:
      return 'assets/images/action_checkmate.png';
    case ActionType.kill:
      return 'assets/images/action_kill.png';
  }
}

class _ActionDialogState extends State<ActionDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController imageAnimation = AnimationController(
      duration: const Duration(milliseconds: 500), vsync: this);
  late Completer<bool> showAction;

  @override
  void initState() {
    super.initState();
    showAction = Completer();
    imageAnimation.addListener(_onEnd);
    imageAnimation.animateTo(1);
  }

  @override
  void dispose() {
    imageAnimation.stop(canceled: true);
    imageAnimation.removeListener(_onEnd);
    imageAnimation.value = 0;
    if (!showAction.isCompleted) {
      showAction.complete(false);
    }
    super.dispose();
  }

  _onEnd() {
    if (imageAnimation.value == 1 && !showAction.isCompleted) {
      showAction.complete(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        children: [
          Center(
            child: FutureBuilder<bool>(
              future: showAction.future,
              initialData: false,
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.hasData && snapshot.data!) {
                  return Image.asset(assets(widget.type));
                }
                return const SizedBox();
              },
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: imageAnimation,
              child: Image.asset('assets/images/action_background.png'),
            ),
          ),
        ],
      ),
    );
  }
}
