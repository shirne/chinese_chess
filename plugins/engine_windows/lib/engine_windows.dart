import 'package:engine_interface/engine_interface.dart';

class EngineWindows extends EngineInterface {
  /// Registers the Windows implementation.
  static void registerWith() {
    EngineInterface.instance = EngineWindows();
  }

  @override
  List<EngineInfo> get supported => [
        const EngineInfo(
          type: EngineType.ucci,
          name: 'eleeye',
          path: 'eleeye/eleeye.exe',
          data: 'eleeye/BOOK.DAT',
        ),
        const EngineInfo(
          type: EngineType.uci,
          name: 'pikafish',
          path: 'pikafish/pikafish.exe',
          data: 'pikafish.nnue',
        ),
      ];

  @override
  String get package => 'engine_windows';

  @override
  EngineInterface create() => EngineWindows();
}
