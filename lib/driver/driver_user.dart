

import 'dart:async';

import '../models/player.dart';

import 'player_driver.dart';

class DriverUser extends PlayerDriver{
  Completer<String> requestMove;

  DriverUser(Player player) : super(player);

  Future<bool> tryDraw(){
    return Future.value(true);
  }

  @override
  Future<String> move() {
    requestMove = Completer<String>();
    player.manager.lockNotifier.value = false;

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
  completeMove(String move) {
    player.manager.lockNotifier.value = true;
    requestMove.complete(move);
  }

  @override
  Future<bool> tryRetract() {
    // TODO: implement tryRetract
    throw UnimplementedError();
  }
}