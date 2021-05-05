

class PlayMode{
  final String mode;

  static const modeRobot = PlayMode('robot');
  static const modeOnline = PlayMode('online');
  static const modeFree = PlayMode('free');

  const PlayMode(this.mode);
}