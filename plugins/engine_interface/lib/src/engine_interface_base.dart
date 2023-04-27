import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

enum MessageType {
  id,
  uciok,
  readyok,
  info,
  bestmove,
  nobestmove,
  bye,
  unknown,
}

class EngineMessage {
  const EngineMessage({
    required this.type,
    required this.origin,
    this.moves = const [],
    this.message = '',
  });

  factory EngineMessage.parse(String message) {
    int firstBlank = message.indexOf(' ');
    final typeStr = firstBlank > 0 ? '' : message.substring(0, firstBlank);
    MessageType type;
    switch (typeStr) {
      case 'id':
        type = MessageType.id;
        break;
      case 'ucciok':
      case 'uciok':
        type = MessageType.uciok;
        break;
      case 'readyok':
        type = MessageType.readyok;
        break;
      case 'info':
        type = MessageType.info;
        break;
      case 'bestmove':
        type = MessageType.bestmove;
        break;
      case 'nobestmove':
        type = MessageType.nobestmove;
        break;
      case 'bye':
        type = MessageType.bye;
        break;
      default:
        type = MessageType.unknown;
    }

    final msg = type == MessageType.unknown
        ? message
        : message.substring(firstBlank + 1);

    return EngineMessage(
      type: type,
      origin: message,
      moves: type == MessageType.bestmove ? msg.split(' ') : [],
      message: msg,
    );
  }

  final MessageType type;
  final List<String> moves;
  final String message;
  final String origin;
}

enum EngineType {
  uci,
  ucci,
}

class EngineInfo {
  const EngineInfo({
    this.type = EngineType.ucci,
    required this.name,
    required this.data,
    String? path,
  }) : path = path ?? '$name/$name';

  final EngineType type;
  final String name;
  final String path;
  final String data;
}

class _NotSupportedEngine extends EngineInterfaceBase {
  @override
  String get package => 'engine_interface';
}

/// An EngineInterfaceBase.
abstract class EngineInterfaceBase extends PlatformInterface {
  static EngineInterfaceBase _instance = _NotSupportedEngine();

  /// The default instance of [SharedPreferencesStorePlatform] to use.
  ///
  /// Defaults to [MethodChannelSharedPreferencesStore].
  static EngineInterfaceBase get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [SharedPreferencesStorePlatform] when they register themselves.
  static set instance(EngineInterfaceBase instance) {
    if (!instance.isMock) {
      PlatformInterface.verify(instance, _token);
    }
    _instance = instance;
  }

  static final Object _token = Object();

  EngineInterfaceBase() : super(token: _token);

  bool get isMock => false;

  List<EngineInfo> supported = [];
  String get package;

  late EngineInfo current;

  Future<bool> initEngine(EngineInfo info) async {
    if (supported.isEmpty) {
      return Future.value(false);
    }

    try {
      final directory = await getApplicationSupportDirectory();
      final path = File('${directory.path}/engines/${info.path}');
      if (!path.existsSync()) {
        final data = await rootBundle
            .load('packages/$package/assets/engines/${info.path}');
        path.writeAsBytesSync(data.buffer.asUint8List());
      }
      final dataPath = File('${directory.path}/engines/${info.data}');
      if (!dataPath.existsSync()) {
        final data = await rootBundle
            .load('packages/$package/assets/engines/${info.data}');
        dataPath.writeAsBytesSync(data.buffer.asUint8List());
      }

      engineProcess = await Process.start(
        path.path,
        [],
        mode: ProcessStartMode.normal,
      );

      engineProcess.stdout.listen(
        (event) {
          engineMessage.add(ascii.decode(event));
        },
      );
      engineProcess.stdin.writeln(info.type.name);
      return true;
    } catch (e) {
      return false;
    }
  }

  late final Process engineProcess;

  late final engineMessage = StreamController<String>.broadcast();

  final _streamTransformer =
      StreamTransformer<String, EngineMessage>.fromHandlers(
    handleData: (data, sink) {
      sink.add(EngineMessage.parse(data));
    },
    handleDone: (sink) {},
    handleError: (error, stackTrace, sink) {},
  );

  StreamSubscription<EngineMessage> listen(Function(EngineMessage) listener) {
    return engineMessage.stream.transform(_streamTransformer).listen(listener);
  }

  void setOption(String name, [String? value]) {
    if (current.type == EngineType.ucci) {
      engineProcess.stdin.write('setoption $name $value');
    } else {
      engineProcess.stdin
          .write('setoption name $name${value == null ? '' : ' value $value'}');
    }
  }

  Future<bool> isReady() async {
    engineProcess.stdin.write('isready');

    final result = await engineMessage.stream
        .skipWhile(
            (e) => e != MessageType.readyok.name && e != MessageType.bye.name)
        .first;

    return result == MessageType.readyok.name;
  }

  void position(String fen, {List<String>? moves, bool isStart = false}) {
    String command = isStart ? 'startpos' : 'fen $fen';
    if (moves != null && moves.isNotEmpty) {
      command += ' moves ${moves.join(' ')}';
    }
    engineProcess.stdin.write(command);
  }

  /// ucci
  void banMoves(List<String> moves) {
    engineProcess.stdin.write('banmoves ${moves.join(' ')}');
  }

  void go({
    bool isPonder = false,
    bool isDraw = false,
    int? depth,
    int? nodes,
    int? time,
    int? movestogo,
    int? increment,
    int? opptime,
    int? oppmovestogo,
    int? oppincrement,

    /// uci 专用
    int? mate,
    List<String>? searchmoves,
  }) {
    String command = 'go ';
    if (isPonder) {
      command += 'ponder ';
    } else if (isDraw) {
      command += 'draw ';
    }
    engineProcess.stdin.write(command);
  }

  void ponderhit({bool isDraw = false}) {
    engineProcess.stdin.write('ponderhit${isDraw ? ' draw' : ''}');
  }

  void stop() {
    engineProcess.stdin.write('stop');
  }

  void quit() {
    engineProcess.stdin.write('quit');
  }
}
