import '../models/player.dart';

import 'driver_online.dart';
import 'driver_robot.dart';
import 'driver_user.dart';

enum PlayerActionType {
  rstMove, // 出招
  rstGiveUp, // 认输
  rstRqstDraw, // 提和
  rstRqstRetract, // 悔棋
  rstDraw, // 同意提和
  rstRetract, // 同意悔棋
  rjctDraw, // 拒绝提和
  rjctRetract; // 拒绝悔棋
}

class PlayerAction {
  PlayerAction({this.type = PlayerActionType.rstMove, this.move})
      : assert(type == PlayerActionType.rstMove && move != null);

  final PlayerActionType type;
  final String? move;
}

abstract class PlayerDriver {
  final Player player;
  bool canBacktrace = true;

  PlayerDriver(this.player);

  Future<void> init();
  Future<void> dispose();

  static PlayerDriver createDriver(
    Player manager, [
    DriverType type = DriverType.user,
  ]) {
    switch (type) {
      case DriverType.robot:
        return DriverRobot(manager);
      case DriverType.online:
        return DriverOnline(manager);
      default:
        return DriverUser(manager);
    }
  }

  /// 申请和棋
  Future<bool> tryDraw();

  /// 申请悔棋
  Future<bool> tryRetract();

  /// 获取走招
  Future<PlayerAction?> move();

  /// 思考
  Future<String> ponder();

  /// 完成走招
  void completeMove(PlayerAction move);

  @override
  String toString() => "$runtimeType ${player.team}";
}

enum DriverType {
  user('user'),
  robot('robot'),
  online('online');

  final String type;
  const DriverType(this.type);
}
