import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

import 'global.dart';
import 'models/engine_type.dart';
import 'models/engine_level.dart';
import 'models/game_setting.dart';

/// 设置页
class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  GameSetting? setting;

  @override
  void initState() {
    super.initState();
    GameSetting.getInstance().then(
      (value) => setState(() {
        setting = value;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = 500;
    if (MediaQuery.of(context).size.width < width) {
      width = MediaQuery.of(context).size.width;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.setting_title),
        actions: [
          TextButton(
            onPressed: () {
              setting?.save().then((v) {
                Navigator.pop(context);
                MyDialog.toast('保存成功', iconType: IconType.success);
              });
            },
            child: const Text(
              '保存',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Center(
        child: setting == null
            ? const CircularProgressIndicator()
            : Container(
                width: width,
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: ListBody(
                    children: [
                      ListTile(
                        title: const Text('AI类型'),
                        trailing: CupertinoSegmentedControl(
                          onValueChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              setting!.robotType = value as EngineType;
                            });
                          },
                          groupValue: setting!.robotType,
                          children: const {
                            EngineType.builtIn: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Text('内置引擎'),
                            ),
                            EngineType.elephantEye: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Text('elephantEye'),
                            ),
                            EngineType.pikafish: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Text('皮卡鱼'),
                            ),
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('AI级别'),
                        trailing: CupertinoSegmentedControl(
                          onValueChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              setting!.robotLevel = value as int;
                            });
                          },
                          groupValue: setting!.robotLevel,
                          children: const {
                            EngineLevel.learn: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Text('初级'),
                            ),
                            EngineLevel.middle: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Text('中级'),
                            ),
                            EngineLevel.master: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Text('大师'),
                            )
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('游戏声音'),
                        trailing: CupertinoSwitch(
                          value: setting!.sound,
                          onChanged: (v) {
                            setState(() {
                              setting!.sound = v;
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('游戏音量'),
                        trailing: CupertinoSlider(
                          value: setting!.soundVolume,
                          min: 0,
                          max: 1,
                          onChanged: (v) {
                            setState(() {
                              setting!.soundVolume = v;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
