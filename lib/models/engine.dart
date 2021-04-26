

import 'dart:io';

class Engine{
  String engine = 'eleeye.exe';
  bool ready;

  Process process;

  Future<Process> init(){
    ready = false;
    String path = Directory.current.path+'/assets/engines/$engine';
    print(path);
    return Process.start(path, []).then((value){
      process = value;
      process.stdin.writeln('ucci');
      ready = true;
    });
  }

  void onMessage(f(String message)){
    if(!ready){
      print('engine is not ready');
    }
    process.stdout.listen((List<int> event){
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
      print('engine is not ready');
    }
    print('command: $command');
    process.stdin.writeln(command);
  }

  void setoption(String option){
    sendCommand('setoption $option');
  }

  void position(String fen){
    sendCommand('position fen $fen');
  }

  void banmoves(List<String> moveList){
    sendCommand('banmoves ${moveList.join(' ')}');
  }

  void go({int time = 3000, int increment = 0, String type = ''}){
    sendCommand('go $type time $time increment $increment');
  }

  void ponderhit(String type){
    sendCommand('ponderhit $type');
  }

  void probe(String fen){
    sendCommand('probe $fen');
  }

  void quit(){
    sendCommand('quit');
    process.kill(ProcessSignal.sigquit);
  }
}