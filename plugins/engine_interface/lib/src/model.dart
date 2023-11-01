import 'dart:convert';

import 'package:collection/collection.dart';

enum MessageType {
  id,
  option,
  uciok('ucciok'),
  readyok,
  info,
  bestmove,
  nobestmove,
  bye,
  unknown;

  final String? alia;
  const MessageType([this.alia]);

  static MessageType? fromName(String? name) {
    if (name == null) return null;
    return values.firstWhereOrNull((e) => e.name == name || e.alia == name);
  }
}

enum EngineCommand {
  setoption,
  isready,
  position,
  banmoves,
  go,
  ponderhit,
  stop,
  quit;

  static EngineCommand? fromName(String? name) {
    if (name == null) return null;
    return values.firstWhereOrNull((e) => e.name == name);
  }
}

enum EngineState {
  uninit,
  init,
  ready,
  idle,
  ponder,
  go,
  quit;
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
    MessageType type = MessageType.fromName(typeStr) ?? MessageType.unknown;

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
  ucci;
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
