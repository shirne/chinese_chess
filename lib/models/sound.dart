
import 'dart:io';
import 'dart:typed_data';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_audio_desktop/flutter_audio_desktop.dart' as ad;

import 'game_setting.dart';

class Sound{
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
  static Duration lastDuration = Duration(milliseconds: 0);
  static ad.AudioPlayer audioDesktopPlayer = ad.AudioPlayer(id: 0)
    ..stream.listen(
        (ad.Audio audio) {
      print('${audio.position} ${audio.duration}');
      if(audio.position >= audio.duration || audio.position < lastDuration) {
        audioDesktopPlayer.stop().then((v){
          audioDesktopPlayer.setPosition(Duration(milliseconds: 0));
        });
        lastDuration = Duration(milliseconds: 0);
      }
      lastDuration = audio.position;
    },
  );

  static GameSetting setting;

  static Future<bool> play(String id) async{
    if(setting == null){
      setting = await GameSetting.getInstance();
    }
    if(!setting.sound)return false;

    String asset = "assets/sounds/$id";
    if(kIsWeb) {
      audioPlayer.setVolume(setting.soundVolume);
      audioPlayer.open(Audio(asset));
    }else if(Platform.isLinux || Platform.isWindows){
      print('play desktop audio: $id');
      audioDesktopPlayer.setVolume(setting.soundVolume);
      audioDesktopPlayer.load(await ad.AudioSource.fromAsset(asset));
      audioDesktopPlayer.play();
    }else{
      audioPlayer.setVolume(setting.soundVolume);
      audioPlayer.open(Audio(asset));
    }
    return true;
  }
}