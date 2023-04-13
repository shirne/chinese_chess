import 'package:engine/engine_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:engine/engine.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final EnginePlatform initialPlatform = EnginePlatform.instance;

  test('getEnginePath', () async {
    print(await initialPlatform.getEnginePath());
  });
}
