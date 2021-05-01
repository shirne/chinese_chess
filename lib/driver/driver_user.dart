

import 'dart:async';

import '../models/player.dart';

import 'player_driver.dart';

class DriverUser extends PlayerDriver{
  Completer<String> requestMove;

  DriverUser(Player manager) : super(manager);

  Future<bool> tryDraw(){
    return Future.value(true);
  }

  @override
  Future<String> move() {
    requestMove = Completer<String>();
    player.manager.lockNotifier.value = false;
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