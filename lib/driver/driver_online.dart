import '../models/game_event.dart';
import '../models/player.dart';
import 'player_driver.dart';

class DriverOnline extends PlayerDriver {
  DriverOnline(Player player) : super(player) {
    canBacktrace = false;
  }

  @override
  Future<bool> tryDraw() {
    return Future.value(true);
  }

  @override
  Future<String?> move() {
    player.manager.add(GameLockEvent(true));
    throw UnimplementedError();
  }

  @override
  Future<String> ponder() {
    throw UnimplementedError();
  }

  @override
  void completeMove(String move) {
    throw UnimplementedError();
  }

  @override
  Future<bool> tryRetract() {
    throw UnimplementedError();
  }
}
