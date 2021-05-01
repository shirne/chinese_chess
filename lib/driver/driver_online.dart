

import 'package:chinese_chess/models/player.dart';

import 'player_driver.dart';

class DriverOnline extends PlayerDriver{
  DriverOnline(Player player) : super(player){
    canBacktrace = false;
  }



  Future<bool> tryDraw(){
    return Future.value(true);
  }

  @override
  Future<String> move() {
    // TODO: implement move
    throw UnimplementedError();
  }

  @override
  Future<String> ponder() {
    // TODO: implement ponder
    throw UnimplementedError();
  }

  @override
  completeMove(String move) {
    // TODO: implement completeMove
    throw UnimplementedError();
  }

  @override
  Future<bool> tryRetract() {
    // TODO: implement tryRetract
    throw UnimplementedError();
  }
}