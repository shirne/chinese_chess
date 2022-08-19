import 'dart:async';

//import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
//import 'package:soundpool/soundpool.dart';

import 'game_setting.dart';

class Sound {
  static const move = 'move2.wav';
  static const capture = 'capture2.wav';
  static const check = 'check2.wav';
  static const click = 'click.wav';
  static const newGame = 'newgame.wav';
  static const loose = 'loss.wav';
  static const win = 'win.wav';
  static const draw = 'draw.wav';
  static const illegal = 'illegal.wav';

  static AudioPlayer audioPlayer = AudioPlayer()
    ..audioCache = AudioCache(prefix: 'assets/sounds/');

  // static final Soundpool pool = Soundpool.fromOptions(
  //     options: const SoundpoolOptions(streamType: StreamType.notification));

  static GameSetting? setting;

  static Future<bool> play(String id) async {
    setting ??= await GameSetting.getInstance();
    if (!setting!.sound) return false;

    await audioPlayer.play(AssetSource(id), volume: setting!.soundVolume);

    // final soundId = await loadAsset(id);
    // await pool.play(soundId);
    return true;
  }

  // static final Map<String, Completer<int>> _loaders = {};
  // static Future<int> loadAsset(String id) async {
  //   if (_loaders.containsKey(id)) {
  //     return _loaders[id]!.future;
  //   }
  //   _loaders[id] = Completer<int>();
  //   rootBundle.load("assets/sounds/$id").then((value) {
  //     _loaders[id]!.complete(pool.load(value));
  //   });

  //   return _loaders[id]!.future;
  // }
}
