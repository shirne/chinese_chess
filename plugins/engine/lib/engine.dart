// You have generated a new plugin project without specifying the `--platforms`
// flag. A plugin project with no platform support was generated. To add a
// platform, run `flutter create -t plugin --platforms <platforms> .` under the
// same directory. You can also find a detailed instruction on how to add
// platforms in the `pubspec.yaml` at
// https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'package:engine_interface/engine_interface.dart';

export 'package:engine_interface/engine_interface.dart';

class Engine {
  static EngineInterfaceBase get engine => EngineInterfaceBase.instance;

  List<EngineInfo> getSupportedEngines() {
    return engine.supported;
  }

  Future<bool> init(EngineInfo info) async {
    final result = await engine.initEngine(info);
    return result;
  }
}
