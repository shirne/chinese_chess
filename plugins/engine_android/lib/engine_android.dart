import 'package:engine_interface/engine_interface.dart';

class EngineAndroid extends EngineInterface {
  /// Registers the Android implementation.
  static void registerWith() {
    EngineInterface.instance = EngineAndroid();
  }

  @override
  String get package => 'engine_android';

  @override
  EngineInterface create() => EngineAndroid();
}
