import 'dart:async';
import 'dart:io';

import 'package:fast_gbk/fast_gbk.dart';

import 'package:file_selector/file_selector.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' as html;

import 'setting.dart';
import 'components/game_bottom_bar.dart';
import 'generated/l10n.dart';
import 'models/play_mode.dart';
import 'widgets/game_wrapper.dart';
import 'models/game_manager.dart';
import 'components/play.dart';
import 'components/edit_fen.dart';

/// 游戏页面
class GameBoard extends StatefulWidget {
  const GameBoard({Key? key}) : super(key: key);

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  GameManager gamer = GameManager.instance;
  PlayMode? mode;

  @override
  void initState() {
    super.initState();
  }

  Widget selectMode() {
    final maxHeight = MediaQuery.of(context).size.height;

    return Center(
      child: SizedBox(
        height: maxHeight * 0.6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  mode = PlayMode.modeRobot;
                });
              },
              icon: const Icon(Icons.android),
              label: Text(S.of(context).mode_robot),
            ),
            ElevatedButton.icon(
              onPressed: () {
                MyDialog.of(context).toast(S.of(context).feature_not_available,
                    iconType: IconType.error);
              },
              icon: const Icon(Icons.wifi),
              label: Text(S.of(context).mode_online),
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  mode = PlayMode.modeFree;
                });
              },
              icon: const Icon(Icons.map),
              label: Text(S.of(context).mode_free),
            ),
            if (kIsWeb)
              TextButton(
                onPressed: () {
                  var link =
                      html.window.document.getElementById('download-apk');
                  if (link == null) {
                    link = html.window.document.createElement('a');
                    link.style.display = 'none';
                    link.setAttribute('id', 'download-apk');
                    link.setAttribute('target', '_blank');
                    link.setAttribute('href', 'chinese-chess.apk');
                    html.window.document
                        .getElementsByTagName('body')[0]
                        .append(link);
                  }
                  link.click();
                },
                child: const Text('Download APK'),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).app_title),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
                icon: const Icon(Icons.menu),
                tooltip: S.of(context).open_menu,
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                });
          },
        ),
        actions: mode == null
            ? null
            : [
                IconButton(
                    icon: const Icon(Icons.swap_vert),
                    tooltip: S.of(context).flip_board,
                    onPressed: () {
                      gamer.flip();
                    }),
                IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: S.of(context).copy_code,
                    onPressed: () {
                      copyFen();
                    }),
                IconButton(
                    icon: const Icon(Icons.airplay),
                    tooltip: S.of(context).parse_code,
                    onPressed: () {
                      applyFen();
                    }),
                IconButton(
                    icon: const Icon(Icons.airplay),
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
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Center(
                    child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 100,
                      height: 100,
                    ),
                    Text(
                      S.of(context).app_title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ))),
            ListTile(
              leading: const Icon(Icons.add),
              title: Text(S.of(context).new_game),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  if (mode == null) {
                    setState(() {
                      mode = PlayMode.modeFree;
                    });
                  }
                  gamer.newGame();
                  //mode = null;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: Text(S.of(context).load_manual),
              onTap: () {
                Navigator.pop(context);
                if (mode == null) {
                  setState(() {
                    mode = PlayMode.modeFree;
                  });
                }
                loadFile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.save),
              title: Text(S.of(context).save_manual),
              onTap: () {
                Navigator.pop(context);
                saveManual();
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: Text(S.of(context).copy_code),
              onTap: () {
                Navigator.pop(context);
                copyFen();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(S.of(context).setting),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            const SettingPage()));
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: mode == null ? selectMode() : PlayPage(mode: mode!),
        ),
      ),
      bottomNavigationBar:
          (mode == null || MediaQuery.of(context).size.width >= 980)
              ? null
              : GameBottomBar(mode!),
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
    ClipboardData? cData = await Clipboard.getData(Clipboard.kTextPlain);
    String fenStr = cData?.text ?? '';
    TextEditingController filenameController =
        TextEditingController(text: fenStr);
    filenameController.addListener(() {
      fenStr = filenameController.text;
    });
    MyDialog.of(context)
        .confirm(
      TextField(
        controller: filenameController,
      ),
      buttonText: S.of(context).apply,
      title: S.of(context).situation_code,
    )
        .then((v) {
      if (v ?? false) {
        if (RegExp(
                r'^[abcnrkpABCNRKP\d]{1,9}(?:/[abcnrkpABCNRKP\d]{1,9}){9}(\s[wb]\s-\s-\s\d+\s\d+)?$')
            .hasMatch(fenStr)) {
          gamer.newGame(fenStr);
        } else {
          MyDialog.of(context).alert(S.of(context).invalid_code);
        }
      }
    });
  }

  copyFen() {
    Clipboard.setData(ClipboardData(text: gamer.fenStr));
    MyDialog.of(context).alert(S.of(context).copy_success);
  }

  saveManual() async {
    String content = gamer.manual.export();
    String filename = '${DateTime.now().millisecondsSinceEpoch ~/ 1000}.pgn';
    if (kIsWeb) {
      _saveManualWeb(content, filename);
    } else if (Platform.isAndroid || Platform.isIOS) {
      _saveManualMobile(content, filename);
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      _saveManualWindow(content, filename);
    }
  }

  _saveManualWeb(String content, String filename) {
    List<int> fData = gbk.encode(content);
    var link = html.window.document.createElement('a');
    link.setAttribute('download', filename);
    link.style.display = 'none';
    link.setAttribute('href', Uri.dataFromBytes(fData).toString());
    html.window.document.getElementsByTagName('body')[0].append(link);
    link.click();
    Future<void>.delayed(const Duration(seconds: 10)).then((v) {
      link.remove();
    });
  }

  _saveManualMobile(String content, String filename) async {
    String? result = await FilesystemPicker.open(
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
      MyDialog.of(context)
          .confirm(
        TextField(
          controller: filenameController,
        ),
        buttonText: 'Save',
        title: S.of(context).save_filename,
      )
          .then((v) {
        if (v ?? false) {
          List<int> fData = gbk.encode(content);
          File('$result/$filename').writeAsBytes(fData).then((File file) {
            MyDialog.of(context).alert(S.of(context).save_success);
          });
        }
      });
    }
  }

  _saveManualWindow(String content, String filename) async {
    final path = await getSavePath(
      suggestedName: filename,
    );
    if (path == null) {
      return;
    }
    final fileData = gbk.encode(content);
    File(path).writeAsBytes(fileData).then((File file) {
      MyDialog.of(context).alert(S.of(context).save_success);
    });
  }

  loadFile() {
    if (kIsWeb) {
      _loadFileWindow();
    } else if (Platform.isAndroid || Platform.isIOS) {
      _loadFileMobile();
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      _loadFileWindow();
    }
  }

  void _loadFileWindow() async {
    final typeGroup = XTypeGroup(
      label: '棋谱文件',
      extensions: ['pgn'],
    );
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file != null) {
      String content = gbk.decode(await file.readAsBytes());
      if (gamer.isStop) {
        gamer.newGame();
      }
      gamer.loadPGN(content);
    }
  }

  void _loadFileMobile() async {
    String? path = await FilesystemPicker.open(
      title: S.of(context).select_pgn_file,
      context: context,
      rootDirectory: Directory(Directory('/').resolveSymbolicLinksSync()),
      fsType: FilesystemType.file,
      folderIconColor: Colors.teal,
      allowedExtensions: ['.pgn', '.PGN'],
      fileTileSelectMode: FileTileSelectMode.wholeTile,
    );

    if (path != null && path.isNotEmpty) {
      if (gamer.isStop) {
        gamer.newGame();
      }
      gamer.loadPGN(path);
    } else {
      // cancel
    }
  }
}
