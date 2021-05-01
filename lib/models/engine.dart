

import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';

class Engine{
  String engine = 'eleeye.exe';
  bool ready;

  Process process;

  Future<Process> init(){
    ready = false;
    if(kIsWeb){
      return Future.value(null);
    }
    String path = Directory.current.path+'/assets/engines/$engine';
    return Process.start(path, []).then((value){
      process = value;
      process.stdin.writeln('ucci');
      ready = true;
      return process;
    });
  }

  void onMessage(f(String message)){
    if(!ready){
      f('Engine is not ready');
      return;
    }
    process.stdout.listen((List<int> event){
      if(!ready) return;
      String lines = String.fromCharCodes(event).trim();
      lines.split('\n').forEach((line) {
        line = line.trim();
        if(line.isNotEmpty) {
          f(line);
        }
      });
    });
  }

  void sendCommand(String command){
    if(!ready){
      print('Engine is not ready');
      return;
    }
    print('command: $command');
    process.stdin.writeln(command);
  }

  void setOption(String option){
    sendCommand('setoption $option');
  }

  void position(String fen){
    sendCommand('position fen $fen');
  }

  void banMoves(List<String> moveList){
    sendCommand('banmoves ${moveList.join(' ')}');
  }

  void go({int time = 0, int increment = 0, String type = '', int depth = 0, int nodes = 0}){
    if(time > 0) {
      sendCommand('go $type time $time increment $increment');
    }else if(depth > 0){
      sendCommand('go depth $depth');
    }else if(depth < 0){
      sendCommand('go depth infinite');
    }else if(nodes > 0){
      sendCommand('go nodes $depth');
    }
  }

  void ponderHit(String type){
    sendCommand('ponderhit $type');
  }

  void probe(String fen){
    sendCommand('probe $fen');
  }

  void stop(){
    sendCommand('stop');
  }

  void quit(){
    sendCommand('quit');
    if(ready) {
      process.kill(ProcessSignal.sigquit);
      process = null;
      ready = false;
    }
  }
}