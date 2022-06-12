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
  Future<String> move() {
    throw UnimplementedError();
  }

  @override
  Future<String> ponder() {
    throw UnimplementedError();
  }

  @override
  completeMove(String move) {
    throw UnimplementedError();
  }

  @override
  Future<bool> tryRetract() {
    throw UnimplementedError();
  }
}
