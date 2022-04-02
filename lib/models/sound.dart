import 'dart:io';
import 'dart:typed_data';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:ffi/ffi.dart' if (dart.library.html) '../html/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:win32/win32.dart' if (dart.library.html) '../html/win32.dart';

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

  static AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();

  static GameSetting? setting;

  static Future<bool> play(String id) async {
    if (setting == null) {
      setting = await GameSetting.getInstance();
    }
    if (!setting!.sound) return false;

    String asset = "assets/sounds/$id";

    // Platform.isLinux not support yet
    if (kIsWeb) {
      audioPlayer.setVolume(setting!.soundVolume);
      audioPlayer.open(Audio(asset));
    } else if (Platform.isWindows) {
      File direct = File(Directory.systemTemp.absolute.path + "/$asset");
      if (!direct.existsSync()) {
        if (!direct.parent.existsSync()) {
          direct.parent.createSync(recursive: true);
        }
        TypedData data = await rootBundle.load(asset);
        await direct.writeAsBytes(data.buffer.asUint8List());
      }
      PlaySound(direct.path.toNativeUtf16(), NULL, SND_ASYNC | SND_FILENAME);
    } else {
      audioPlayer.setVolume(setting!.soundVolume);
      audioPlayer.open(Audio(asset));
    }
    return true;
  }
}
