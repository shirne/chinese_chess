import 'package:engine_interface/engine_interface.dart';

class EngineLinux extends EngineInterfaceBase {
  /// Registers the Linux implementation.
  static void registerWith() {
    EngineInterfaceBase.instance = EngineLinux();
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
  String get package => 'engine_linux';
}
