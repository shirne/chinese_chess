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

  DriverType _driverType;
  PlayerDriver? _driver;

  Player(
    this.team,
    this.manager, {
    this.title = '',
    DriverType type = DriverType.user,
  }) : _driverType = type;

  set driverType(DriverType type) {
    _driverType = type;
    if (_driver != null) _driver!.dispose();
    _driver = PlayerDriver.createDriver(this, _driverType);
    _driver!.init();
  }

  DriverType get driverType => _driverType;
  PlayerDriver get driver => _driver!;

  bool get isUser => _driverType == DriverType.user;

  bool get isRobot => _driverType == DriverType.robot;

  bool get canBacktrace => _driver?.canBacktrace ?? false;

  // 通知界面，从界面上过来的着法不需要调用
  Future<PlayerAction> onMove(PlayerAction move) {
    logger.info('onmove');
    manager.add(GameMoveEvent(move));

    return Future.value(move);
  }

  Future<bool> onDraw() => _driver?.tryDraw() ?? Future.value(false);

  Future<PlayerAction?> move() => _driver?.move() ?? Future.value(null);

  void completeMove(PlayerAction move) {
    _driver?.completeMove(move);
  }

  void dispose() {
    _driver?.dispose();
  }
}
