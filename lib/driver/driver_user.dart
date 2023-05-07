import 'dart:async';

import '../models/game_event.dart';
import '../models/player.dart';

import 'player_driver.dart';

class DriverUser extends PlayerDriver {
  late Completer<PlayerAction> requestMove;

  DriverUser(Player player) : super(player);

  @override
  Future<bool> tryDraw() {
    return Future.value(true);
  }

  @override
  Future<PlayerAction?> move() {
    requestMove = Completer<PlayerAction>();
    player.manager.add(GameLockEvent(false));

    return requestMove.future;
  }

  @override
  Future<String> ponder() {
    // TODO: implement ponder
    throw UnimplementedError();
  }

  @override
  void completeMove(PlayerAction move) {
    if (!requestMove.isCompleted) {
      requestMove.complete(move);
    }
  }

  @override
  Future<bool> tryRetract() {
    // TODO: implement tryRetract
    throw UnimplementedError();
  }

  @override
  Future<void> init() async {}
  @override
  Future<void> dispose() async {}
}
