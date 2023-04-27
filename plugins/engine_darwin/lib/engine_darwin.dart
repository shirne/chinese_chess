import 'package:engine_interface/engine_interface.dart';

class EngineDarwin extends EngineInterfaceBase {
  /// Registers the Darwin implementation.
  static void registerWith() {
    EngineInterfaceBase.instance = EngineDarwin();
  }

  @override
  String get package => 'engine_darwin';
}
