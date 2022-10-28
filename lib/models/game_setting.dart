import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'engine_type.dart';

class GameSetting {
  static SharedPreferences? storage;
  static GameSetting? _instance;
  static const cacheKey = 'setting';

  EngineType robotType = EngineType.builtIn;
  int robotLevel = 10;
  bool sound = true;
  double soundVolume = 1;

  GameSetting({
    this.robotType = EngineType.builtIn,
    this.robotLevel = 10,
    this.sound = true,
    this.soundVolume = 1,
  });

  GameSetting.fromJson(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return;
    Map<String, dynamic> json = jsonDecode(jsonStr);
    if (json.containsKey('robotType')) {
      robotType = EngineType.fromName(json['robotType']) ?? EngineType.builtIn;
    }
    if (json.containsKey('robotLevel')) {
      robotLevel = json['robotLevel'];
      if (robotLevel < 10 || robotLevel > 12) {
        robotLevel = 10;
      }
    }
    if (json.containsKey('sound')) {
      sound = json['sound'];
    }
    if (json.containsKey('soundVolume')) {
      soundVolume = json['soundVolume'];
    }
  }

  static Future<GameSetting> getInstance() async {
    _instance ??= await GameSetting.init();
    return _instance!;
  }

  static Future<GameSetting> init() async {
    storage ??= await SharedPreferences.getInstance();
    String? json = storage!.getString(cacheKey);
    return GameSetting.fromJson(json);
  }

  Future<bool> save() async {
    storage ??= await SharedPreferences.getInstance();
    storage!.setString(cacheKey, toString());
    return true;
  }

  @override
  String toString() => jsonEncode({
        'robotType': robotType.name,
        'robotLevel': robotLevel,
        'sound': sound,
        'soundVolume': soundVolume,
      });
}
