import 'package:chinese_chess/models/game_event.dart';

import '../driver/player_driver.dart';
import '../global.dart';
import 'game_manager.dart';

class Player {
  //ChessItem item;
  GameManager manager;
  String lastPosition = '';
  String team = 'r';
  String title = '红方';

  int totalTime = 0;
  int stepTime = 0;

  late DriverType _driverType;
  late PlayerDriver driver;

  Player(
    this.team,
    this.manager, {
    this.title = '',
    DriverType type = DriverType.user,
  }) {
    _driverType = type;
  }

  set driverType(DriverType type) {
    _driverType = type;
    driver = PlayerDriver.createDriver(this, _driverType);
  }

  DriverType get driverType => _driverType;

  bool get isUser => _driverType == DriverType.user;

  bool get isRobot => _driverType == DriverType.robot;

  bool get canBacktrace => driver.canBacktrace;

  // 通知界面，从界面上过来的着法不需要调用
  Future<String> onMove(String move) {
    logger.info('onmove');
    manager.add(GameMoveEvent(move));

    return Future.value(move);
  }

  Future<bool> onDraw() => driver.tryDraw();

  Future<String> move() => driver.move();

  completeMove(String move) {
    driver.completeMove(move);
  }
}
