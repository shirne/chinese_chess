import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../foundation/customer_notifier.dart';
import '../global.dart';
import 'engine_type.dart';

class Engine extends CustomNotifier<String> {
  Engine(this.engine);

  final EngineType engine;
  List<Completer<String>> readyCompleters = [];
  Completer<bool>? stopCompleter;
  bool ready = false;

  Process? process;

  Future<Process?> init() {
    ready = false;
    if (!isSupportEngine) {
      return Future.value(null);
    }

    String path = '${Directory.current.path}/assets/engines/${engine.path}';
    if (!File(path).existsSync()) {
      path =
          '${Directory.current.path}/data/flutter_assets/assets/engines/${engine.path}';
    }
    return Process.start(path, [], mode: ProcessStartMode.normal).then((value) {
      process = value;
      ready = true;
      process?.stdout.listen(onMessage);
      process?.stdin.writeln(engine.scheme);
      return process!;
    });
  }

  static bool get isSupportEngine {
    if (kIsWeb) {
      return false;
    }
    if (Platform.isWindows) {
      return true;
    }

    return false;
  }

  void onMessage(List<int> event) {
    String lines = String.fromCharCodes(event).trim();
    lines.split('\n').forEach((line) {
      line = line.trim();
      if (line == 'bye') {
        ready = false;
        process = null;
        if (stopCompleter != null && !stopCompleter!.isCompleted) {
          stopCompleter?.complete(true);
        }
      } else if (line.isNotEmpty && hasListeners) {
        if (line.startsWith('nobestmove') || line.startsWith('bestmove ')) {
          if (stopCompleter != null && !stopCompleter!.isCompleted) {
            stopCompleter!.complete(true);
          } else if (readyCompleters.isNotEmpty) {
            readyCompleters.removeAt(0).complete(line);
          }
        }
        notifyListeners(line);
      }
    });
  }

  Future<String> requestMove(
    String fen, {
    int time = 0,
    int increment = 0,
    String type = '',
    int depth = 0,
    int nodes = 0,
  }) {
    Completer<String> readyCompleter = Completer();
    stop().then((b) {
      if (b) {
        readyCompleters.add(readyCompleter);
        position(fen);
        go(
          time: time,
          increment: increment,
          type: type,
          depth: depth,
          nodes: nodes,
        );
      } else {
        readyCompleter.complete('isbusy');
      }
    });
    return readyCompleter.future;
  }

  void sendCommand(String command) {
    if (!ready) {
      logger.info('Engine is not ready');
      return;
    }
    logger.info('command: $command');
    process?.stdin.writeln(command);
  }

  void setOption(String option) {
    sendCommand('setoption $option');
  }

  void position(String fen) {
    sendCommand('position fen $fen');
  }

  void banMoves(List<String> moveList) {
    sendCommand('banmoves ${moveList.join(' ')}');
  }

  void go({
    int time = 0,
    int increment = 0,
    String type = '',
    int depth = 0,
    int nodes = 0,
  }) {
    if (time > 0) {
      sendCommand('go $type time $time increment $increment');
    } else if (depth > 0) {
      sendCommand('go depth $depth');
    } else if (depth < 0) {
      sendCommand('go depth infinite');
    } else if (nodes > 0) {
      sendCommand('go nodes $depth');
    }
  }

  void ponderHit(String type) {
    sendCommand('ponderhit $type');
  }

  void probe(String fen) {
    sendCommand('probe $fen');
  }

  Future<bool> stop() {
    if (!ready || (stopCompleter != null && !stopCompleter!.isCompleted)) {
      return Future.value(false);
    }
    stopCompleter = Completer();
    sendCommand('stop');
    return stopCompleter!.future;
  }

  void quit() {
    sendCommand('quit');
    ready = false;
  }
}
