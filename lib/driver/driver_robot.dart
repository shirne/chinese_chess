

import '../models/chess_rule.dart';

import '../models/chess_item.dart';

import '../models/chess_fen.dart';
import '../models/player.dart';

import 'player_driver.dart';

class DriverRobot extends PlayerDriver{
  DriverRobot(Player player) : super(player);

  Future<bool> tryDraw(){
    return Future.value(true);
  }

  @override
  Future<String> move() async {
    print('thinking');
    List<String> moves = getAlbeMoves(player.manager.fen, player.team == 'r'?0:1);
    moves.shuffle();
    print(moves[0]);

    return await player.onMove(moves[0]);
  }

  getAlbeMoves(ChessFen fen, int team){
    List<String> moves = [];
    List<ChessItem> items = fen.getAll();
    items.forEach((item) {
      if(item.team == team) {
        moves +=
            ChessRule(fen).movePoints(item.position).map<String>((toPos) => item
                .position.toCode() + toPos).toList();
      }
    });
    return moves;
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