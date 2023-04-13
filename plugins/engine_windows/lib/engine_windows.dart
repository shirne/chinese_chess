


import 'package:engine_interface/engine_interface.dart';

class EngineWindows extends EngineInterfaceBase {
  
  @override
  Future<String> getEnginePath() {
    return Future.value('windows path');
  }
  
  @override
  Future<bool> initEngine() {
    // TODO: implement initEngine
    throw UnimplementedError();
  }
}
