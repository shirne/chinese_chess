

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

  DriverType _driverType;
  PlayerDriver driver;

  Player(this.team, this.manager,{this.title = '', DriverType type = DriverType.user}){
    this.driverType = type;
  }

  set driverType(DriverType type){
    _driverType = type;
    this.driver = PlayerDriver.createDriver(this, _driverType);
  }
  DriverType get driverType{
    return _driverType;
  }

  bool get isUser{
    return _driverType == DriverType.user;
  }
  bool get isRobot{
    return _driverType == DriverType.robot;
  }

  bool get canBacktrace{
    return driver.canBacktrace;
  }

  // 通知界面，从界面上过来的着法不需要调用
  Future<String> onMove(String move){
    print('onmove');
    manager.moveNotifier.value = move;

    Future.delayed(Duration(milliseconds: 500)).then((v){
      manager.moveNotifier.value = '';
      manager.switchPlayer();
    });

    return Future.value(move);
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