import 'package:engine/engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

import 'global.dart';
import 'models/game_setting.dart';

/// 设置页
class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

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
        title: Text(context.l10n.settingTitle),
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
                              setting!.info = value as EngineInfo;
                            });
                          },
                          groupValue: setting!.info,
                          children: {
                            builtInEngine: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Text('内置引擎'),
                            ),
                            for (var engine in Engine().getSupportedEngines())
                              engine: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Text(engine.name),
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
                              setting!.engineLevel = value as int;
                            });
                          },
                          groupValue: setting!.engineLevel,
                          children: const {
                            10: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Text('初级'),
                            ),
                            11: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 11,
                              ),
                              child: Text('中级'),
                            ),
                            12: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text('大师'),
                            ),
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
