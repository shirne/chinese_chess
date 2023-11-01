import 'dart:async';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:cchess_engine/cchess_engine.dart';
import 'package:engine_interface/engine_interface.dart';

class EngineWeb extends EngineInterface {
  /// Registers the Windows implementation.
  static void registerWith(Registrar? registrar) {
    EngineInterface.instance = EngineWeb();
  }

  @override
  List<EngineInfo> get supported => [
        const EngineInfo(
          type: EngineType.uci,
          name: 'eleeye',
          path: r'eleeye\eleeye.exe',
          data: r'eleeye\BOOK.DAT',
        ),
      ];

  @override
  String get package => 'engine_web';

  @override
  EngineInterface create() => EngineWeb();

  String currentFen = '';
  List<String>? currentMoves;

  @override
  bool get inited => true;

  @override
  Future<bool> initEngine(EngineInfo info) async {
    engineMessage.add(
      EngineMessage(
        type: MessageType.uciok,
        origin: MessageType.uciok.name,
      ),
    );
    return true;
  }

  @override
  void sendCommand(String cmd) {
    final msgs = cmd.split(RegExp(r'\s+'));
    final cmdType = EngineCommand.fromName(msgs.first);
    int mode = 0;
    switch (cmdType) {
      case EngineCommand.setoption:
        break;
      case EngineCommand.isready:
        engineMessage.add(
          EngineMessage(
            type: MessageType.uciok,
            origin: MessageType.uciok.name,
          ),
        );
        break;
      case EngineCommand.position:
        for (var key in msgs) {
          if (mode != 0) {
            if (mode == 1) {
              currentFen = key;
              mode = 0;
            } else if (mode == 2) {
              currentMoves ??= [];
              currentMoves!.add(key);
            }
            continue;
          }
          if (key == 'startpos') {
            currentFen = '';
          } else if (key == 'fen') {
            mode = 1;
          } else if (key == 'moves') {
            mode = 2;
          }
        }
        break;
      case EngineCommand.banmoves:
        break;
      case EngineCommand.go:
        Future(() async {
          XQIsoSearch.level = 10;
          final move = await XQIsoSearch.getMove(IsoMessage(currentFen));
          engineMessage.add(
            EngineMessage(
              type: MessageType.bestmove,
              moves: [move],
              origin: '${MessageType.bestmove.name} $move',
            ),
          );
        });

        break;
      case EngineCommand.ponderhit:
        break;
      case EngineCommand.stop:
        engineMessage.add(
          const EngineMessage(type: MessageType.nobestmove, origin: 'bye'),
        );
        break;
      case EngineCommand.quit:
        engineMessage.add(
          const EngineMessage(type: MessageType.bye, origin: 'bye'),
        );
        break;
      case null:
        break;
    }
  }
}
