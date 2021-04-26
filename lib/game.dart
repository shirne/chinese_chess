


import 'package:flutter/material.dart';

import 'models/Gamer.dart';
import 'play.dart';

class GameWrapper extends StatefulWidget{
  @override
  State<GameWrapper> createState() => GameWrapperState();

}

class GameWrapperState extends State<GameWrapper> {
  Gamer gamer;
  @override
  void initState() {
    super.initState();
    if(gamer != null){
      print('gamer inited');
      gamer.destroy();
    }
    gamer = Gamer();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('中国象棋'),
        /*actions: [
          IconButton(icon: Icon(Icons.minimize), onPressed: (){

          }),
          IconButton(icon: Icon(Icons.zoom_out_map), onPressed: (){

          }),
          IconButton(icon: Icon(Icons.clear), color: Colors.red, onPressed: (){

          })
        ],*/
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Center(
                child:
                    Column(children: [
                      Image.asset('assets/images/logo.png'),
                      Text(
                        '中国象棋',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ],)

              )
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('新对局'),
              onTap: (){
                print('new game');
              },
            ),
            ListTile(
              leading: Icon(Icons.description),
              title: Text('加载棋谱'),
              onTap: (){
                print('new game');
              },
            ),
            ListTile(
              leading: Icon(Icons.save),
              title: Text('保存棋谱'),
              onTap: (){
                print('new game');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('设置'),
              onTap: (){
                print('new game');
              },
            ),
          ],
        ),
      ),
        body:PlayPage()
    );
  }

  @override
  void dispose() {
    super.dispose();
    print('gamer destroy');
    gamer.destroy();
    gamer = null;
  }
}