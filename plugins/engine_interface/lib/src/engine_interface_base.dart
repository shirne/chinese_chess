import 'dart:async';
import 'dart:io';

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
  });

  EngineMessage.parse(String message)
      : this(
          type: mapType(message),
          origin: message,
        );

  static MessageType mapType(String message) {
    switch (message.substring(0, message.indexOf(' '))) {
      case 'id':
        return MessageType.id;
      case 'ucciok':
      case 'uciok':
        return MessageType.uciok;
      case 'readyok':
        return MessageType.readyok;
      case 'info':
        return MessageType.info;
      case 'bestmove':
        return MessageType.bestmove;
      case 'nobestmove':
        return MessageType.nobestmove;
      case 'bye':
        return MessageType.bye;
      default:
        return MessageType.unknown;
    }
  }

  final MessageType type;
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
    String? path,
  }) : path = path ?? '$name/$name.o';

  final EngineType type;
  final String name;
  final String path;
}

/// An EngineInterfaceBase.
abstract class EngineInterfaceBase {
  List<EngineInfo> supported = [];

  late EngineInfo current;
  Future<bool> initEngine(EngineInfo engine);

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

  position(String fen, {List<String>? moves, bool isStart = false}) {
    String command = isStart ? 'startpos' : 'fen $fen';
    if (moves != null && moves.isNotEmpty) {
      command += ' moves ${moves.join(' ')}';
    }
    engineProcess.stdin.write(command);
  }

  /// ucci
  banMoves(List<String> moves) {
    engineProcess.stdin.write('banmoves ${moves.join(' ')}');
  }

  go({
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

  ponderhit({bool isDraw = false}) {
    engineProcess.stdin.write('ponderhit${isDraw ? ' draw' : ''}');
  }

  stop() {
    engineProcess.stdin.write('stop');
  }

  quit() {
    engineProcess.stdin.write('quit');
  }
}
