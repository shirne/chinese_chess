

/// An EngineInterfaceBase.
abstract class EngineInterfaceBase {
  Future<String> getEnginePath();

  Future<bool> initEngine();
}
