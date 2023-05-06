import 'dart:convert';

enum MessageType {
  id,
  option,
  uciok,
  readyok,
  info,
  bestmove,
  nobestmove,
  bye,
  unknown,
}

enum EngineState {
  uninit,
  init,
  ready,
  idle,
  ponder,
  go,
  quit,
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
    final typeStr = firstBlank > 0 ? message.substring(0, firstBlank) : message;
    MessageType type;
    switch (typeStr) {
      case 'id':
        type = MessageType.id;
        break;
      case 'ucciok':
      case 'uciok':
        type = MessageType.uciok;
        break;
      case 'option':
        type = MessageType.option;
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

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'moves': moves,
        'message': message,
        'origin': origin,
      };

  @override
  String toString() => jsonEncode(toJson());
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

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'name': name,
        'path': path,
        'data': data,
      };

  @override
  String toString() => jsonEncode(toJson());
}
