// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';

import 'package:engine_interface/engine_interface.dart';

export 'package:engine_interface/engine_interface.dart';

class Engine {
  static EngineInterface get engine => EngineInterface.instance;

  bool get started => engine.inited;

  List<EngineInfo> getSupportedEngines() {
    return engine.supported;
  }

  Future<bool> init([EngineInfo? info]) async {
    if (info == null && engine.supported.isEmpty) {
      throw const NotSupportedException();
    }
    info ??= engine.supported.first;

    try {
      final result = await engine.initEngine(info);
      return result;
    } catch (_) {}

    return false;
  }

  StreamSubscription<EngineMessage> listen(Function(EngineMessage) listener) {
    return engine.listen(listener);
  }

  Future<bool> isReady() {
    return engine.isReady();
  }

  Future<String> requestMove(
    String fen, {
    List<String>? moves,
    bool isDraw = false,
    bool isPonder = false,
    int time = 0,
    int increment = 0,
    String type = '',
    int depth = 0,
    int nodes = 0,
  }) async {
    await stop();
    position(fen, moves: moves);
    return await go(
      time: time,
      increment: increment,
      isDraw: isDraw,
      isPonder: isPonder,
      depth: depth,
      nodes: nodes,
    );
  }

  void position(String fen, {List<String>? moves, bool isStart = false}) {
    return engine.position(fen, moves: moves, isStart: isStart);
  }

  /// ucci
  void banMoves(List<String> moves) {
    return engine.banMoves(moves);
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
    return engine.go(
      isPonder: isPonder,
      depth: depth,
      nodes: nodes,
      time: time,
      movestogo: movestogo,
      increment: increment,
      opptime: opptime,
      oppmovestogo: oppmovestogo,
      oppincrement: oppincrement,
      isDraw: isDraw,
      mate: mate,
      movetime: movetime,
      isInfinite: isInfinite,
      searchmoves: searchmoves,
    );
  }

  void ponderhit({bool isDraw = false}) {
    return engine.ponderhit(isDraw: isDraw);
  }

  Future<bool> stop() {
    return engine.stop();
  }

  Future<bool> quit() {
    return engine.quit();
  }
}

class NotSupportedException implements Exception {
  final String message;
  const NotSupportedException([this.message = 'unsupported platform']);
}
