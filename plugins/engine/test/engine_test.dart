
import 'package:flutter_test/flutter_test.dart';
import 'package:engine/engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final Engine engine = Engine();

  test('getEnginePath', () async {
    print(engine.getSupportedEngines());
  });
}
