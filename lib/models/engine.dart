

import 'dart:io';

import 'package:flutter/foundation.dart';

import '../foundation/customer_notifier.dart';

class Engine extends CustomNotifier<String>{
  String engine = 'eleeye.exe';
  bool ready;

  Process process;

  Future<Process> init(){
    ready = false;
    if(!isSupportEngine){
      return Future.value(null);
    }

    String path = Directory.current.path+'/assets/engines/$engine';
    if(!File(path).existsSync()){
      path = Directory.current.path+'/data/flutter_assets/assets/engines/$engine';
    }
    return Process.start(path, [], mode: ProcessStartMode.normal).then((value){
      process = value;
      ready = true;
      process.stdout.listen(onMessage);
      process.stdin.writeln('ucci');
      return process;
    });
  }

  static bool get isSupportEngine{
    if(kIsWeb){
      return false;
    }
    if(Platform.isWindows){
      return true;
    }

    return false;
  }

  void onMessage(List<int> event){
    String lines = String.fromCharCodes(event).trim();
    lines.split('\n').forEach((line) {
      line = line.trim();
      if(line == 'bye'){
        ready = false;
        process = null;
      }else if(line.isNotEmpty && this.hasListeners) {
        this.notifyListeners(line);
      }
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
    ready = false;
  }
}