import 'dart:convert';

import 'package:engine/engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

const builtInEngine = EngineInfo(name: 'builtIn', data: '');

class GameSetting {
  static SharedPreferences? storage;
  static GameSetting? _instance;
  static const cacheKey = 'setting';

  EngineInfo info = builtInEngine;
  int engineLevel = 10;
  bool sound = true;
  double soundVolume = 1;

  GameSetting({
    this.info = builtInEngine,
    this.engineLevel = 10,
    this.sound = true,
    this.soundVolume = 1,
  });

  GameSetting.fromJson(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return;
    Map<String, dynamic> json = jsonDecode(jsonStr);
    if (json.containsKey('engine_info')) {
      info = Engine().getSupportedEngines().firstWhere(
            (e) => e.name == json['engine_info'],
            orElse: () => builtInEngine,
          );
    }
    if (json.containsKey('engine_level')) {
      engineLevel = json['engine_level'];
      if (engineLevel < 10 || engineLevel > 12) {
        engineLevel = 10;
      }
    }
    if (json.containsKey('sound')) {
      sound = json['sound'];
    }
    if (json.containsKey('sound_volume')) {
      soundVolume = json['sound_volume'];
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
        'engine_info': info.name,
        'engine_level': engineLevel,
        'sound': sound,
        'sound_volume': soundVolume,
      });
}
