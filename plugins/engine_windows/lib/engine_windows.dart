import 'package:engine_interface/engine_interface.dart';

class EngineWindows extends EngineInterfaceBase {
  /// Registers the Windows implementation.
  static void registerWith() {
    EngineInterfaceBase.instance = EngineWindows();
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
          data: 'pikafish.nnue',
        ),
      ];

  @override
  String get package => 'engine_windows';
}
