import 'package:engine_interface/engine_interface.dart';

class EngineAndroid extends EngineInterfaceBase {
  /// Registers the Android implementation.
  static void registerWith() {
    EngineInterfaceBase.instance = EngineAndroid();
  }

  @override
  String get package => 'engine_android';
}
