
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gbk2utf8/gbk2utf8.dart';

import 'models/game_manager.dart';
import 'play.dart';

class GameWrapper extends StatefulWidget{
  @override
  State<GameWrapper> createState() => GameWrapperState();

}

class GameWrapperState extends State<GameWrapper> {
  GameManager gamer;

  @override
  void initState() {
    super.initState();
    if(gamer != null){
      print('gamer inited');
      gamer.destroy();
    }
    gamer = GameManager();
  }

  Future<void> _showDialog(String message, List<Widget> buttons,{ String title = 'Alert', barrierDismissible = false}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: message.split('\n').map<Widget>((item)=>Text(item)),
            ),
          ),
          actions: buttons,
        );
      },
    );
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
            this._showDialog('是否立即退出',
                [
                  TextButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    child: Text('暂不退出'),
                  ),
                  TextButton(
                      onPressed: (){
                        if(!kIsWeb){
                          Isolate.current.pause();
                          exit(0);
                        }
                      },
                      child: Text('立即退出',style: TextStyle(color:Colors.red)),
                  )
                ]
            );
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
                kIsWeb ? requestFile() : loadFile();
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
        body:Center(
            child:PlayPage()
        )
    );
  }

  @override
  void dispose() {
    print('gamer destroy');
    gamer.destroy();
    gamer = null;
    super.dispose();
  }

  void requestFile() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['.pgn','.PGN']
    );

    if(result != null) {
      print(result.files.single);
      if(result.files.single.path != null) {
        File file = File(result.files.single.path);
        print(file);
      }else{
        String content = gbk.decode(result.files.single.bytes);
        print(content);
      }
    } else {
      // User canceled the picker
    }
  }

  void loadFile() async {
    String path = await FilesystemPicker.open(
      title: '选择棋谱文件',
      context: context,
      rootDirectory: Directory('/'),
      fsType: FilesystemType.file,
      folderIconColor: Colors.teal,
      allowedExtensions: ['.pgn','.PGN'],
      fileTileSelectMode: FileTileSelectMode.wholeTile,
    );

    if(path != null) {
      print(path);
    } else {
      // User canceled the picker
    }
  }
}