import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'logger.dart';
import 'model.dart';

class _NotSupportedEngine extends EngineInterface {
  @override
  String get package => 'engine_interface';

  @override
  EngineInterface create() => _NotSupportedEngine();
}

/// An EngineInterfaceBase.
abstract class EngineInterface extends PlatformInterface {
  static EngineInterface _instance = _NotSupportedEngine();

  /// The default instance of [EngineInterface] to use.
  ///
  /// Defaults to [EngineInterface].
  static EngineInterface get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [EngineInterface] when they register themselves.
  static set instance(EngineInterface instance) {
    if (!instance.isMock) {
      PlatformInterface.verify(instance, _token);
    }
    _instance = instance;
  }

  static final Object _token = Object();

  EngineInterface() : super(token: _token);

  bool get isMock => false;

  List<EngineInfo> supported = [];
  String get package;

  EngineInterface create();

  EngineInfo? _current;
  EngineInfo get current => _current!;
  bool _inited = false;
  bool get inited => _inited;

  Completer<bool>? initLock;

  Future<bool> initEngine(EngineInfo info) async {
    logger.fine('initEngine: $info');
    if (engineProcess != null) {
      if (info == current) {
        return true;
      }
      await stop();
      await quit();
      initLock = null;
    }
    if (await initLock?.future ?? false) {
      return _inited;
    }

    try {
      initLock = Completer();
      _inited = false;
      _current = info;
      final directory = await getApplicationSupportDirectory();
      final path = File('${directory.path}/engines/${info.path}');
      if (!path.existsSync()) {
        if (!path.parent.existsSync()) {
          path.parent.createSync(recursive: true);
        }
        final data = await rootBundle
            .load('packages/$package/assets/engines/${info.path}');
        path.writeAsBytesSync(data.buffer.asUint8List(), flush: true);

        // add +x for exe file
        if (Platform.isLinux) {
          final result = await Process.run(
            'chmod',
            ['+x', info.name],
            runInShell: true,
            workingDirectory: path.parent.path,
          );
          if (result.exitCode != 0) {
            logger.warning(result.stderr);
          } else {
            logger.fine(result.stdout);
          }
        }
      }
      final dataPath = File('${directory.path}/engines/${info.data}');
      if (!dataPath.existsSync()) {
        if (!dataPath.parent.existsSync()) {
          dataPath.parent.createSync(recursive: true);
        }
        final data = await rootBundle
            .load('packages/$package/assets/engines/${info.data}');
        dataPath.writeAsBytesSync(data.buffer.asUint8List(), flush: true);
      }

      okCompleter = Completer();
      engineProcess = await Process.start(
        path.path,
        [],
        mode: ProcessStartMode.normal,
      );

      engineProcess!.stdout.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );
      engineProcess!.stdin.writeln(info.type.name);

      _inited = (await okCompleter?.future) ?? false;

      /// ucci默认启用毫秒制
      if (_inited && info.type == EngineType.ucci) {
        setOption('usemillisec', 'true');
      }
      initLock?.complete(_inited);
      return _inited;
    } catch (e) {
      logger.warning('$e', e);
      _current = null;
      initLock?.complete(false);
      return false;
    }
  }

  Process? engineProcess;

  final engineMessage = StreamController<EngineMessage>.broadcast();

  StreamSubscription<EngineMessage> listen(Function(EngineMessage) listener) {
    return engineMessage.stream.listen(listener);
  }

  EngineState state = EngineState.uninit;

  Completer<bool>? okCompleter;
  Completer<bool>? readyCompleter;
  Completer<String>? moveCompleter;
  Completer<bool>? stopCompleter;
  Completer<bool>? quitCompleter;

  void _onMessage(List<int> event) {
    final events = ascii.decode(event).trim().split(RegExp(r'[\r\n]+'));
    for (var estr in events) {
      if (estr.trim().isEmpty) continue;
      logger.fine('engine message: $estr');
      final message = EngineMessage.parse(estr.trim());
      if (message.type == MessageType.uciok) {
        state = EngineState.init;
        if (okCompleter?.isCompleted ?? true) {
          okCompleter?.complete(true);
        }
      } else if (message.type == MessageType.readyok) {
        state = EngineState.ready;
        if (readyCompleter?.isCompleted ?? true) {
          readyCompleter?.complete(true);
        }
      } else if (message.type == MessageType.bestmove) {
        state = EngineState.idle;
        if (moveCompleter?.isCompleted ?? true) {
          moveCompleter?.complete(message.message);
        }
      } else if (message.type == MessageType.nobestmove) {
        state = EngineState.idle;
        if (stopCompleter?.isCompleted ?? true) {
          stopCompleter?.complete(true);
        }
      } else if (message.type == MessageType.bye) {
        state = EngineState.quit;
        if (quitCompleter?.isCompleted ?? true) {
          quitCompleter?.complete(true);
        }
      }
      engineMessage.add(message);
    }
  }

  void _onError(err) {}
  void _onDone() {}

  void sendCommand(String cmd) {
    logger.fine('send command: $cmd');
    engineProcess?.stdin.writeln(cmd);
  }

  void setOption(String name, [String? value]) {
    if (current.type == EngineType.ucci) {
      sendCommand('setoption $name $value');
    } else {
      sendCommand(
          'setoption name $name${value == null ? '' : ' value $value'}');
    }
  }

  Future<bool> isReady() async {
    readyCompleter = Completer();
    sendCommand('isready');

    final isReady = await readyCompleter?.future;
    return isReady ?? false;
  }

  void position(String fen, {List<String>? moves, bool isStart = false}) {
    String command = isStart ? 'startpos' : 'fen $fen';
    if (moves != null && moves.isNotEmpty) {
      command += ' moves ${moves.join(' ')}';
    }
    sendCommand('position $command');
  }

  /// ucci
  void banMoves(List<String> moves) {
    sendCommand('banmoves ${moves.join(' ')}');
  }

  Future<String> go({
    bool isPonder = false,
    int? depth,
    int? nodes,
    int? time,
    int? movestogo,
    int? increment,
    int? opptime,
    int? oppmovestogo,
    int? oppincrement,

    /// ucci 专用
    bool isDraw = false,

    /// uci 专用
    int? mate,
    int? movetime,
    bool isInfinite = false,
    List<String>? searchmoves,
  }) {
    String command = 'go ';
    if (current.type == EngineType.ucci) {
      if (isPonder) {
        command += 'ponder ';
      } else if (isDraw) {
        command += 'draw ';
      }
      if (depth != null) {
        command += 'depth ${depth < 0 ? 'infinite' : depth} ';
      } else if (nodes != null) {
        command += 'nodes $nodes ';
      } else if (time != null) {
        command += 'time $time ';
        if (movestogo != null) {
          command += 'movestogo $movestogo ';
        } else if (increment != null) {
          command += 'increment $increment ';
        }

        if (opptime != null) {
          command += 'opptime $opptime ';
          if (oppmovestogo != null) {
            command += 'oppmovestogo $oppmovestogo ';
          } else if (oppincrement != null) {
            command += 'oppincrement $oppincrement ';
          }
        }
      }
    } else {
      if (isPonder) {
        command += 'ponder ';
      }

      if (depth != null) {
        command += 'depth ${depth < 0 ? 'infinite' : depth} ';
      }
      if (nodes != null) {
        command += 'nodes $nodes ';
      }
      if (mate != null) {
        command += 'mate $mate ';
      }
      if (searchmoves != null) {
        command += 'searchmoves ${searchmoves.join(' ')} ';
      }
      if (time != null) {
        command += 'wtime $time ';
      }
      if (opptime != null) {
        command += 'btime $opptime} ';
      }
      if (increment != null) {
        command += 'winc $increment ';
      }
      if (oppincrement != null) {
        command += 'binc $oppincrement ';
      }
      if (movestogo != null) {
        command += 'movestogo $movestogo ';
      }
      if (movetime != null) {
        command += 'movetime $movetime ';
      }
      if (isInfinite) {
        command += 'infinite';
      }
    }
    if (isPonder) {
      state = EngineState.ponder;
    } else {
      state = EngineState.go;
    }
    moveCompleter = Completer();
    sendCommand(command);
    return moveCompleter!.future;
  }

  void ponderhit({bool isDraw = false}) {
    state = EngineState.ponder;
    sendCommand('ponderhit${isDraw ? ' draw' : ''}');
  }

  Future<bool> stop() async {
    stopCompleter = Completer();
    sendCommand('stop');
    await stopCompleter!.future;

    state = EngineState.idle;
    return true;
  }

  Future<bool> quit() {
    quitCompleter = Completer();
    sendCommand('quit');
    return quitCompleter!.future;
  }
}
