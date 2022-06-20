import 'package:audioplayers/audioplayers.dart';

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

  static AudioPlayer audioPlayer = AudioPlayer();

  static GameSetting? setting;

  static Future<bool> play(String id) async {
    setting ??= await GameSetting.getInstance();
    if (!setting!.sound) return false;

    String asset = "sounds/$id";

    audioPlayer.setVolume(setting!.soundVolume);
    audioPlayer.play(AssetSource(asset));
    return true;
  }
}
