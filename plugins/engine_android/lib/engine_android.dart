
import 'package:engine_interface/engine_interface.dart';

class EngineAndroid extends EngineInterfaceBase {
  
  @override
  Future<String> getEnginePath() {
    return Future.value('android path');
  }
  
  @override
  Future<bool> initEngine() {
    // TODO: implement initEngine
    throw UnimplementedError();
  }
}
