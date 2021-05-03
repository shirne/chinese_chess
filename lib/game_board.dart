import 'dart:async';
import 'dart:io';

import 'package:shirne_dialog/shirne_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gbk2utf8/gbk2utf8.dart';
import 'package:universal_html/html.dart' as html;

import 'widgets/game_wrapper.dart';
import 'models/game_manager.dart';
import 'play.dart';
import 'edit_fen.dart';

class GameBoard extends StatefulWidget {
  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  GameManager gamer;

  @override
  void initState() {
    super.initState();
    gamer = context.findAncestorStateOfType<GameWrapperState>().gamer;
  }

  Future<bool> confirm(message,
      {String buttonText = 'OK',
      String title = 'Alert',
      String cancelText = 'Cancel'}) {
    return MyDialog.of(context).confirm(message).result;
  }

  alert(message) {
    MyDialog.of(context).alert(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('中国象棋'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
                icon: Icon(Icons.menu),
                tooltip: '菜单',
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                });
          },
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.copy),
              tooltip: '复制局面代码',
              onPressed: () {
                copyFen();
              }),
          IconButton(
              icon: Icon(Icons.airplay),
              tooltip: '粘贴局面代码',
              onPressed: () {
                applyFen();
              }),
          IconButton(
              icon: Icon(Icons.airplay),
              tooltip: '编辑局面',
              onPressed: () {
                editFen();
              }),
          /*IconButton(icon: Icon(Icons.minimize), onPressed: (){

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
          })*/
        ],
      ),
      drawer: Drawer(
        semanticLabel: '菜单',
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Center(
                    child: Column(
                  children: [
                    Image.asset('assets/images/logo.png'),
                    Text(
                      '中国象棋',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ))),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('新对局'),
              onTap: () {
                gamer.newGame();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.description),
              title: Text('加载棋谱'),
              onTap: () {
                Navigator.pop(context);
                kIsWeb ? requestFile() : loadFile();
              },
            ),
            ListTile(
              leading: Icon(Icons.save),
              title: Text('保存棋谱'),
              onTap: () {
                Navigator.pop(context);
                saveManual();
              },
            ),
            ListTile(
              leading: Icon(Icons.copy),
              title: Text('复制局面代码'),
              onTap: () {
                Navigator.pop(context);
                copyFen();
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('设置'),
              onTap: () {
                alert('暂未支持');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: PlayPage(),
      ),
    );
  }

  editFen() {
    Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (BuildContext context) {
        return GameWrapper(child: EditFen(fen: gamer.fenStr));
      }),
    ).then((fenStr) {
      if (fenStr != null && fenStr.isNotEmpty) {
        gamer.newGame(fenStr);
      }
    });
  }

  applyFen() async {
    ClipboardData cData = await Clipboard.getData(Clipboard.kTextPlain);
    String fenStr = cData.text;
    TextEditingController filenameController =
        TextEditingController(text: fenStr);
    filenameController.addListener(() {
      fenStr = filenameController.text;
    });
    confirm(
            TextField(
              controller: filenameController,
            ),
            buttonText: '应用',
            title: '局面代码')
        .then((v) {
      if (v) {
        if(RegExp(r'^[abcnrkpABCNRKP\d]{1,9}(?:/[abcnrkpABCNRKP\d]{1,9}){9}(\s[wb]\s-\s-\s\d+\s\d+)?$').hasMatch(fenStr)) {
          gamer.newGame(fenStr);
        }else{
          alert('无效代码');
        }
      }
    });
  }

  copyFen() {
    Clipboard.setData(ClipboardData(text: gamer.fenStr));
    alert('复制成功');
  }

  saveManual() async {
    String content = gamer.manual.export();
    String filename = '${DateTime.now().millisecondsSinceEpoch ~/ 1000}.pgn';
    if (kIsWeb) {
      List<int> fData = gbk.encode(content);
      var link = html.window.document.createElement('a');
      link.setAttribute('download', filename);
      link.style.display = 'none';
      link.setAttribute('href', Uri.dataFromBytes(fData).toString());
      html.window.document.getElementsByTagName('body')[0].append(link);
      link.click();
      Future<void>.delayed(Duration(seconds: 10)).then((v) {
        link.remove();
      });
    } else {
      String result = await FilesystemPicker.open(
        title: '选择保存位置',
        context: context,
        rootDirectory: Directory(Directory('/').resolveSymbolicLinksSync()),
        fsType: FilesystemType.folder,
        folderIconColor: Colors.teal,
        fileTileSelectMode: FileTileSelectMode.wholeTile,
      );
      if (result != null && result.isNotEmpty) {
        TextEditingController filenameController =
            TextEditingController(text: filename);
        filenameController.addListener(() {
          filename = filenameController.text;
        });
        confirm(
                TextField(
                  controller: filenameController,
                ),
                buttonText: 'Save',
                title: '保存文件名')
            .then((v) {
          if (v) {
            List<int> fData = gbk.encode(content);
            File('$result/$filename').writeAsBytes(fData).then((File file) {
              alert('保存成功');
            });
          }
        });
      }
    }
  }

  void requestFile() async {
    FilePickerResult result = await FilePicker.platform
        .pickFiles(allowedExtensions: ['.pgn', '.PGN']);

    if (result != null) {
      print(result.files.single);
      if (result.files.single.path != null) {
        File file = File(result.files.single.path);
        print(file);
      } else {
        String content = gbk.decode(result.files.single.bytes);
        print(content);
        gamer.loadPGN(content);
      }
    } else {
      // User canceled the picker
    }
  }

  void loadFile() async {
    String path = await FilesystemPicker.open(
      title: '选择棋谱文件',
      context: context,
      rootDirectory: Directory(Directory('/').resolveSymbolicLinksSync()),
      fsType: FilesystemType.file,
      folderIconColor: Colors.teal,
      allowedExtensions: ['.pgn', '.PGN'],
      fileTileSelectMode: FileTileSelectMode.wholeTile,
    );

    if (path != null) {
      print(path);
      gamer.loadPGN(path);
    } else {
      print(path);
    }
  }
}
