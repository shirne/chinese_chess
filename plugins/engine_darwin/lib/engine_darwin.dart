import 'package:engine_interface/engine_interface.dart';

class EngineDarwin extends EngineInterface {
  /// Registers the Darwin implementation.
  static void registerWith() {
    EngineInterface.instance = EngineDarwin();
  }

  @override
  List<EngineInfo> get supported => [
        const EngineInfo(
          type: EngineType.ucci,
          name: 'eleeye',
          data: 'eleeye/BOOK.DAT',
        ),
        const EngineInfo(
          type: EngineType.uci,
          name: 'pikafish',
          data: 'pikafish/pikafish.nnue',
        ),
      ];

  @override
  String get package => 'engine_darwin';

  @override
  EngineInterface create() => EngineDarwin();
}
