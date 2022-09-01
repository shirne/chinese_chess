import 'dart:async';

import '../models/game_event.dart';
import '../models/player.dart';

import 'player_driver.dart';

class DriverUser extends PlayerDriver {
  late Completer<String> requestMove;

  DriverUser(Player player) : super(player);

  @override
  Future<bool> tryDraw() {
    return Future.value(true);
  }

  @override
  Future<String?> move() {
    requestMove = Completer<String>();
    player.manager.add(GameLockEvent(false));

    // 招法提示
    player.manager.requestHelp();

    return requestMove.future;
  }

  @override
  Future<String> ponder() {
    // TODO: implement ponder
    throw UnimplementedError();
  }

  @override
  void completeMove(String move) {
    if (!requestMove.isCompleted) {
      requestMove.complete(move);
    }
  }

  @override
  Future<bool> tryRetract() {
    // TODO: implement tryRetract
    throw UnimplementedError();
  }
}
