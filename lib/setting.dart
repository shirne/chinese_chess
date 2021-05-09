

import 'package:chinese_chess/models/game_setting.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'generated/l10n.dart';
import 'models/engine_type.dart';

class SettingPage extends StatefulWidget{
  @override
  State<SettingPage> createState() => _SettingPageState();

}

class _SettingPageState extends State<SettingPage> {
  GameSetting setting;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    GameSetting.getInstance().then((value) => setting = value);
  }

  @override
  Widget build(BuildContext context) {
    double width = 500;
    if(MediaQuery.of(context).size.width < width){
      width = MediaQuery.of(context).size.width;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).setting_title),
        actions: [
          TextButton(onPressed: (){
            setting.save();
          }, child: Text('保存', style: TextStyle(color: Colors.white),)
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: width,
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: ListBody(
              children: [
                ListTile(
                  title: Text('AI类型'),
                    trailing: CupertinoSegmentedControl(
                      onValueChanged: (value){
                        setting.robotType = value;
                      },
                      groupValue: setting.robotType,
                      children: {
                        EngineType.builtIn: Text('内置引擎'),
                        EngineType.elephantEye: Text('elephantEye')
                      },
                    )
                ),
                ListTile(
                  title: Text('游戏声音'),
                  trailing: CupertinoSwitch(
                    value: setting.sound,
                    onChanged: (v){
                      setState(() {
                        setting.sound = v;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: Text('游戏音量'),
                  trailing: CupertinoSlider(
                    value: setting.soundVolume,
                    onChanged: (v){
                      setState(() {
                        setting.soundVolume = v;
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