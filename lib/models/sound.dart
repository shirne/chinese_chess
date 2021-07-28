
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/foundation.dart';
import 'package:dart_vlc/dart_vlc.dart' as vlc;

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
  static vlc.Player vlcPlayer = vlc.Player(id: 69420);

  static GameSetting? setting;

  static Future<bool> play(String id) async{
    if(setting == null){
      setting = await GameSetting.getInstance();
    }
    if(!setting!.sound)return false;

    String asset = "assets/sounds/$id";
    if(kIsWeb) {
      audioPlayer.setVolume(setting!.soundVolume);
      audioPlayer.open(Audio(asset));
    }else if(Platform.isLinux || Platform.isWindows){
      vlcPlayer.setVolume(setting!.soundVolume);
      vlcPlayer.open(await vlc.Media.asset(asset));
    }else{
      audioPlayer.setVolume(setting!.soundVolume);
      audioPlayer.open(Audio(asset));
    }
    return true;
  }
}