
import 'package:engine_interface/engine_interface.dart';

class EngineLinux extends EngineInterfaceBase {
  
  @override
  Future<String> getEnginePath() {
    return Future.value('linux path');
  }
  
  @override
  Future<bool> initEngine() {
    // TODO: implement initEngine
    throw UnimplementedError();
  }
}
