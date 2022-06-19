enum GameEventType {
  move,
  engine,
  player,
  load,
  result,
  lock,
  step,
  flip,
}

abstract class GameEvent<T> {
  GameEventType type;
  T? data;
  GameEvent(this.type, [this.data]);

  @override
  String toString() => '$type $data';

  static GameEventType? eventType(Type t) {
    switch (t) {
      case GameMoveEvent:
        return GameEventType.move;
      case GameEngineEvent:
        return GameEventType.engine;
      case GamePlayerEvent:
        return GameEventType.player;
      case GameLoadEvent:
        return GameEventType.load;
      case GameResultEvent:
        return GameEventType.result;
      case GameLockEvent:
        return GameEventType.lock;
      case GameStepEvent:
        return GameEventType.step;
      case GameFlipEvent:
        return GameEventType.flip;
    }
    return null;
  }
}

class GameMoveEvent extends GameEvent<String> {
  GameMoveEvent(String move) : super(GameEventType.move, move);
}

class GameEngineEvent extends GameEvent<String> {
  GameEngineEvent(String move) : super(GameEventType.engine, move);
}

class GamePlayerEvent extends GameEvent<int> {
  GamePlayerEvent(int hand) : super(GameEventType.player, hand);
}

class GameLoadEvent extends GameEvent<int> {
  GameLoadEvent(int state) : super(GameEventType.load, state);
}

class GameResultEvent extends GameEvent<String> {
  GameResultEvent(String move) : super(GameEventType.result, move);
}

class GameLockEvent extends GameEvent<bool> {
  GameLockEvent(bool isLock) : super(GameEventType.lock, isLock);
}

class GameStepEvent extends GameEvent<String> {
  GameStepEvent(String step) : super(GameEventType.step, step);
}

class GameFlipEvent extends GameEvent<bool> {
  GameFlipEvent(bool isFlip) : super(GameEventType.flip, isFlip);
}
