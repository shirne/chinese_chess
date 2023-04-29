import 'package:engine_interface/engine_interface.dart';

class EngineDarwin extends EngineInterface {
  /// Registers the Darwin implementation.
  static void registerWith() {
    EngineInterface.instance = EngineDarwin();
  }

  @override
  String get package => 'engine_darwin';
}
