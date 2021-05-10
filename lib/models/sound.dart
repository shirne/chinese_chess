
import 'dart:typed_data';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/services.dart';

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

  static Future<bool> play(String id) async{

    audioPlayer.open(Audio("assets/sounds/$id"));
    return true;
  }
}