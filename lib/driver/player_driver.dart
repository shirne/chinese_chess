import '../models/player.dart';

import 'driver_online.dart';
import 'driver_robot.dart';
import 'driver_user.dart';

abstract class PlayerDriver {
  final Player player;
  bool canBacktrace = true;

  // 认输
  static const rstGiveUp = 'giveup';
  // 提和
  static const rstRqstDraw = 'rqstrdraw';
  // 悔棋
  static const rstRqstRetract = 'rqstretract';
  // 同意提和
  static const rstDraw = 'draw';
  // 同意悔棋
  static const rstRetract = 'retract';

  static const rstActions = [
    rstGiveUp,
    rstRqstDraw,
    rstRqstRetract,
    rstDraw,
    rstRetract
  ];

  static bool isAction(String move) {
    return rstActions.contains(move) || move.contains(rstRqstDraw);
  }

  PlayerDriver(this.player);

  static PlayerDriver createDriver(Player manager,
      [DriverType type = DriverType.user]) {
    switch (type) {
      case DriverType.robot:
        return DriverRobot(manager);
      case DriverType.online:
        return DriverOnline(manager);
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

class DriverType {
  final String type;

  static const user = DriverType('user');
  static const robot = DriverType('robot');
  static const online = DriverType('online');

  const DriverType(this.type);
}
