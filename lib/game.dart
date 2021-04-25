


import 'package:flutter/material.dart';

import 'models/Gamer.dart';
import 'play.dart';

class GameWrapper extends StatefulWidget{
  @override
  State<GameWrapper> createState() => GameWrapperState();

}

class GameWrapperState extends State<GameWrapper> {
  Gamer gamer = Gamer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body:PlayPage()
    );
  }
}