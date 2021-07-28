
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'engine_type.dart';

class GameSetting{
  static SharedPreferences? storage;
  static GameSetting? _instance;
  static const cacheKey = 'setting';

  String robotType = EngineType.builtIn;
  int robotLevel = 10;
  bool sound = true;
  double soundVolume = 1;

  GameSetting({this.robotType = EngineType.builtIn, this.robotLevel = 10,this.sound = true,this.soundVolume = 1});

  GameSetting.fromJson(String? jsonStr){
    if(jsonStr == null || jsonStr.isEmpty)return;
    Map<String, dynamic> json = JsonDecoder().convert(jsonStr);
    if(json.containsKey('robotType')) {
      this.robotType = json['robotType'];
    }
    if(json.containsKey('robotLevel')) {
      this.robotLevel = json['robotLevel'];
      if(this.robotLevel <10 || this.robotLevel > 12){
        this.robotLevel = 10;
      }
    }
    if(json.containsKey('sound')) {
      this.sound = json['sound'];
    }
    if(json.containsKey('soundVolume')) {
      this.soundVolume = json['soundVolume'];
    }
  }

  static Future<GameSetting> getInstance() async{
    if(_instance == null){
      _instance = await GameSetting.init();
    }
    return _instance!;
  }

  static Future<GameSetting> init() async{
    if(storage == null) {
      storage = await SharedPreferences.getInstance();
    }
    String? json = storage!.getString(cacheKey);
    return GameSetting.fromJson(json);
  }

  Future<bool> save() async{
    if(storage == null) {
      storage = await SharedPreferences.getInstance();
    }
    storage!.setString(cacheKey, this.toString());
    return true;
  }

  @override
  String toString() {
    return JsonEncoder().convert({
      'robotType': robotType,
      'robotLevel': robotLevel,
      'sound': sound,
      'soundVolume': soundVolume,
    });
  }
}