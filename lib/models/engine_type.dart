enum EngineType {
  elephantEye('eleeye/eleeye.exe'),
  pikafish('pikafish/pikafish.exe', 'uci'),
  builtIn();

  final String path;
  final String scheme;

  const EngineType([this.path = '', this.scheme = 'ucci']);

  static EngineType? fromName(String? name) {
    for (var e in values) {
      if (e.name == name) {
        return e;
      }
    }
    return null;
  }
}
