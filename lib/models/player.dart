

import 'package:chinese_chess/models/game_manager.dart';

import '../driver/player_driver.dart';
import 'chess_item.dart';
import 'chess_pos.dart';

class Player{
  ChessItem item;
  GameManager manager;
  String lastPosition = '';
  String team = 'r';
  String title = '红方';

  int totalTime = 0;
  int stepTime = 0;

  PlayerDriver driver;

  Player(this.team, this.manager,{this.title = '', DriverType driverType = DriverType.user}){
    this.driver = PlayerDriver.createDriver(this, driverType);
  }

  bool get canBacktrace{
    return driver.canBacktrace;
  }

  // 通知界面，从界面上过来的着法不需要调用
  Future<String> onMove(String move) async{
    manager.moveNotifier.value = move;

    await Future.delayed(Duration(milliseconds: 300));

    Future.delayed(Duration(milliseconds: 500)).then((v){
      manager.moveNotifier.value = '';
      manager.switchPlayer();
    });

    return move;
  }

  Future<bool> onDraw(){
    return driver.tryDraw();
  }

  Future<String> move(){
    return driver.move();
  }

  completeMove(ChessPos from, ChessPos next){
    driver.completeMove('${from.toCode()}${next.toCode()}');
  }
}