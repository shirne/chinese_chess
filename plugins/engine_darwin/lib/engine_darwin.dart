

import 'package:engine_interface/engine_interface.dart';

class EngineDarwin extends EngineInterfaceBase {
  
  @override
  Future<String> getEnginePath() {
    return Future.value('darwin path');
  }
  
  @override
  Future<bool> initEngine() {
    // TODO: implement initEngine
    throw UnimplementedError();
  }
}
