
import 'package:engine_interface/engine_interface.dart';

class EngineLinux extends EngineInterfaceBase {
  @override
  List<EngineInfo> get supported => [
    const EngineInfo(type: EngineType.ucci, name: 'eleeye'),
    const EngineInfo(type: EngineType.uci, name: 'pikafish'),
  ];
  

  @override
  Future<bool> initEngine(EngineInfo engine) {
    // TODO: implement initEngine
    throw UnimplementedError();
  }
  
 
}
