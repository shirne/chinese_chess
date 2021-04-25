
import 'package:flutter/material.dart';

import 'chess.dart';



class PlayPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => PlayPageState();

}

class PlayPageState extends State<PlayPage> {
  @override
  Widget build(BuildContext context) {
    return  Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Row(
          children: [
            SizedBox(
              child: Chess(),
            ),
            SizedBox(width: 10,),
            Expanded(child: Text('infos'))
          ],
        ),
      );
  }
}

