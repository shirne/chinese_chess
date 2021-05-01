

import '../models/player.dart';

import 'driver_online.dart';
import 'driver_robot.dart';
import 'driver_user.dart';

abstract class PlayerDriver{
  final Player player;
  bool canBacktrace = true;

  PlayerDriver(this.player);


  static PlayerDriver createDriver(Player manager,[DriverType type = DriverType.user]){
    switch(type){
      case DriverType.robot:
        return DriverRobot(manager);
        break;
      case DriverType.online:
        return DriverOnline(manager);
        break;
      default:
        return DriverUser(manager);
    }
  }

  Future<bool> tryDraw();
  Future<bool> tryRetract();

  Future<String> move();

  Future<String> ponder();

  completeMove(String move);
}

class DriverType{
  final String type;

  static const user = DriverType('user');
  static const robot = DriverType('robot');
  static const online = DriverType('online');

  const DriverType(this.type);
}