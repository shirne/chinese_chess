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

import 'generated/l10n.dart';
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
    return MyDialog.of(context).confirm(message);
  }

  alert(message) {
    MyDialog.of(context).alert(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).app_title),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
                icon: Icon(Icons.menu),
                tooltip: S.of(context).open_menu,
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                });
          },
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.copy),
              tooltip: S.of(context).copy_code,
              onPressed: () {
                copyFen();
              }),
          IconButton(
              icon: Icon(Icons.airplay),
              tooltip: S.of(context).parse_code,
              onPressed: () {
                applyFen();
              }),
          IconButton(
              icon: Icon(Icons.airplay),
              tooltip: S.of(context).edit_code,
              onPressed: () {
                editFen();
              }),
          /*IconButton(icon: Icon(Icons.minimize), onPressed: (){

          }),
          IconButton(icon: Icon(Icons.zoom_out_map), onPressed: (){

          }),
          IconButton(icon: Icon(Icons.clear), color: Colors.red, onPressed: (){
            this._showDialog(S.of(context).exit_now,
                [
                  TextButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                    child: Text(S.of(context).dont_exit),
                  ),
                  TextButton(
                      onPressed: (){
                        if(!kIsWeb){
                          Isolate.current.pause();
                          exit(0);
                        }
                      },
                      child: Text(S.of(context).yes_exit,style: TextStyle(color:Colors.red)),
                  )
                ]
            );
          })*/
        ],
      ),
      drawer: Drawer(
        semanticLabel: S.of(context).menu,
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
                      S.of(context).app_title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ))),
            ListTile(
              leading: Icon(Icons.add),
              title: Text(S.of(context).new_game),
              onTap: () {
                gamer.newGame();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.description),
              title: Text(S.of(context).load_manual),
              onTap: () {
                Navigator.pop(context);
                kIsWeb ? requestFile() : loadFile();
              },
            ),
            ListTile(
              leading: Icon(Icons.save),
              title: Text(S.of(context).save_manual),
              onTap: () {
                Navigator.pop(context);
                saveManual();
              },
            ),
            ListTile(
              leading: Icon(Icons.copy),
              title: Text(S.of(context).copy_code),
              onTap: () {
                Navigator.pop(context);
                copyFen();
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text(S.of(context).setting),
              onTap: () {
                alert(S.of(context).feature_not_available);
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
            buttonText: S.of(context).apply,
            title: S.of(context).situation_code)
        .then((v) {
      if (v) {
        if(RegExp(r'^[abcnrkpABCNRKP\d]{1,9}(?:/[abcnrkpABCNRKP\d]{1,9}){9}(\s[wb]\s-\s-\s\d+\s\d+)?$').hasMatch(fenStr)) {
          gamer.newGame(fenStr);
        }else{
          alert(S.of(context).invalid_code);
        }
      }
    });
  }

  copyFen() {
    Clipboard.setData(ClipboardData(text: gamer.fenStr));
    alert(S.of(context).copy_success);
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
        title: S.of(context).select_directory_save,
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
                title: S.of(context).save_filename)
            .then((v) {
          if (v) {
            List<int> fData = gbk.encode(content);
            File('$result/$filename').writeAsBytes(fData).then((File file) {
              alert(S.of(context).save_success);
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
      title: S.of(context).select_pgn_file,
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
