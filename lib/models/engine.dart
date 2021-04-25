

import 'dart:io';

class Engine{
  String engine = 'eleeye.exe';

  Process process;

  Future<Process> init(){
    String path = Directory.current.path+'/assets/engines/$engine';
    print(path);
    return Process.start(path, []).then((value){
      process = value;
      process.stdin.writeln('ucci');
    });
  }

  void onMessage(f(String message)){
    process.stdout.listen((List<int> event){
      String line = String.fromCharCodes(event);
      f(line);
    });
  }

  void sendCommand(String command){
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
  }
}