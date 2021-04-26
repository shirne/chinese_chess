import 'package:flutter/material.dart';

import 'chess.dart';
import 'widgets/tab_card.dart';

class PlayPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PlayPageState();
}

class PlayPageState extends State<PlayPage> {
  @override
  Widget build(BuildContext context) {

    BoxDecoration decoration = BoxDecoration(border: Border.all(color: Colors.grey),borderRadius: BorderRadius.all(Radius.circular(2)));
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: 521,
            child: Chess(),
          ),
          Container(
            width: 420,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(2)),
              boxShadow: [BoxShadow(
                color: Color.fromRGBO(0, 0, 0, .1),
                offset: Offset(1, 1),
                blurRadius: 1.0,
                spreadRadius: 1.0
              )]
            ),
            child: Column(
              children: [
                Container(
                  height: 200,
                  decoration: decoration,
                  child: Text('棋局信息'),
                ),
                SizedBox(height: 10,),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ListTile(
                              leading: Icon(Icons.person),
                              title: Text('黑方'),
                            ),
                            ListTile(
                              leading: Icon(Icons.person),
                              title: Text('红方'),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 200,
                        padding: EdgeInsets.all(10),
                        decoration: decoration,
                        child: ListView(
                          children: [
                            Text('着法1'),
                            Text('着法2'),
                            Text('着法3'),
                            Text('着法4'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  height: 200,
                  decoration: decoration,
                  child: TabCard(
                      titlePadding:EdgeInsets.symmetric( vertical: 10, horizontal: 30),
                    titles:[
                      Text('推荐招法'),
                      Text('注解')
                    ],
                    bodies:[
                      Text('推荐招法 body'),
                      Text('注解 body')
                    ]
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
