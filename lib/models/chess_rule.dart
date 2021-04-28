
import 'chess_map.dart';

class ChessRule{

  /// 检查是否被将军
  bool checkCheckMate(team, fen){

    return false;
  }

  List<String> movePoints(ChessItem item, ChessMap map){
    print(item);
    if(item == null)return [];
    switch(item.code){
      case 'p':
        return moveP(item, map);
      case 'c':
        return moveC(item, map);
      case 'r':
        return moveR(item, map);
      case 'n':
        return moveN(item, map);
      case 'b':
        return moveB(item, map);
      case 'a':
        return moveA(item, map);
      case 'k':
        return moveK(item, map);
      default:
        return [];
    }
  }
  List<String> moveP(ChessItem item, ChessMap map){
    List<String> points = [];
    XYKey point = XYKey.fromCode(item.position);
    [[1,0],[0,1],[-1,0],[0,-1]].forEach((m) {
      if(item.team == 'r'){
        // 不允许退
        if(m[1] < 0){
          return;
        }
        // 不过河不能横走
        if(point.y < 5 && m[0] != 0){
          return;
        }
      }else{
        // 不允许退
        if(m[1] > 0){
          return;
        }
        // 不过河不能横走
        if(point.y > 4 && m[0] != 0){
          return;
        }
      }
      XYKey newPoint = XYKey(point.x + m[0], point.y + m[1]);
      if(newPoint.x < 0 || newPoint.x > 8){
        return;
      }
      if(newPoint.y < 0 || newPoint.y > 9){
        return;
      }
      // 目标位置是否有己方子
      if(map.hasChessAt(newPoint, team:item.team)){
        return;
      }
      points.add(newPoint.toCode());
    });
    return points;
  }
  List<String> moveC(ChessItem item, ChessMap map){
    List<String> points = [];
    XYKey point = XYKey.fromCode(item.position);
    [[-1,0],[1,0],[0,-1],[0,1]].forEach((step) {
      bool hasRack = false;
      XYKey movePoint = XYKey(point.x + step[0], point.y + step[1]);

      while(movePoint.x >= 0 && movePoint.x <= 8 && movePoint.y >= 0 && movePoint.y <= 9){

        // 是否有炮架
        ChessItem current = map.getChessAt(movePoint);
        // print([movePoint, current]);
        if(!current.isBlank){
          // 遇到对方子就吃
          if(hasRack) {
            if (current.team != item.team) {
              points.add(movePoint.toCode());
            }
            break;
          }
          hasRack = true;
        }
        if(!hasRack){
          points.add(movePoint.toCode());
        }

        movePoint.x+= step[0];
        movePoint.y+= step[1];
      }
    });
    return points;
  }
  List<String> moveR(ChessItem item, ChessMap map){
    List<String> points = [];
    XYKey point = XYKey.fromCode(item.position);
    [[-1,0],[1,0],[0,-1],[0,1]].forEach((step) {
      XYKey movePoint = XYKey(point.x + step[0], point.y + step[1]);
      while(movePoint.x >= 0 && movePoint.x <= 8 && movePoint.y >= 0 && movePoint.y <= 9){

        // 遇到已方子立即停止
        ChessItem current = map.getChessAt(movePoint);
        if(!current.isBlank && current.team == item.team){
          break;
        }
        points.add(movePoint.toCode());
        // 遇到对方子吃完停止
        if(!current.isBlank){
          break;
        }

        movePoint.x += step[0];
        movePoint.y += step[1];
      }
    });
    return points;
  }
  List<String> moveN(ChessItem item, ChessMap map){
    List<String> points = [];
    XYKey point = XYKey.fromCode(item.position);
    [
      [2,1],
      [1,2],
      [-2,-1],
      [-1,-2],
      [-2,1],
      [-1,2],
      [2,-1],
      [1,-2]
    ].forEach((m) {
      XYKey newPoint = XYKey(point.x + m[0], point.y + m[1]);
      if(newPoint.x < 0 || newPoint.x > 8){
        return;
      }
      if(newPoint.y < 0 || newPoint.y > 9){
        return;
      }
      // 是否别马腿
      if(map.hasChessAt(XYKey(point.x + m[0] ~/ 2, point.y + m[1] ~/ 2))){
        print([newPoint, point.x + m[0] ~/ 2, point.y + m[1] ~/ 2]);
        return;
      }
      // 目标位置是否有己方子
      if(map.hasChessAt(newPoint, team:item.team)){
        return;
      }
      points.add(newPoint.toCode());
    });
    return points;
  }
  List<String> moveB(ChessItem item, ChessMap map){
    List<String> points = [];
    XYKey point = XYKey.fromCode(item.position);
    [[2,2],[-2,2],[-2,-2],[2,-2]].forEach((m) {
      XYKey newPoint = XYKey(point.x + m[0], point.y + m[1]);
      if(newPoint.x < 0 || newPoint.x > 8){
        return;
      }
      if(item.team == 'r'){
        if(newPoint.y < 0 || newPoint.y > 4){
          return;
        }
      }else{
        if(newPoint.y < 5 || newPoint.y > 9){
          return;
        }
      }
      // 是否别象腿
      if(map.hasChessAt(XYKey(point.x + m[0] ~/ 2, point.y + m[1] ~/ 2))){
        return;
      }
      // 目标位置是否有己方子
      if(map.hasChessAt(newPoint, team:item.team)){
        return;
      }
      points.add(newPoint.toCode());
    });
    return points;
  }
  List<String> moveA(ChessItem item, ChessMap map){
    List<String> points = [];
    XYKey point = XYKey.fromCode(item.position);
    [[1,1],[-1,1],[-1,-1],[1,-1]].forEach((m) {
      XYKey newPoint = XYKey(point.x + m[0], point.y + m[1]);
      if(newPoint.x < 3 || newPoint.x > 5){
        return;
      }
      if(item.team == 'r'){
        if(newPoint.y < 0 || newPoint.y > 2){
          return;
        }
      }else{
        if(newPoint.y < 7 || newPoint.y > 9){
          return;
        }
      }
      // 目标位置是否有己方子
      if(map.hasChessAt(newPoint, team:item.team)){
        return;
      }
      points.add(newPoint.toCode());
    });
    return points;
  }
  List<String> moveK(ChessItem item, ChessMap map){
    List<String> points = [];
    XYKey point = XYKey.fromCode(item.position);
    [[1,0],[0,1],[-1,0],[0,-1]].forEach((m) {
      XYKey newPoint = XYKey(point.x + m[0], point.y + m[1]);
      if(newPoint.x < 3 || newPoint.x > 5){
        return;
      }
      if(item.team == 'r'){
        if(newPoint.y < 0 || newPoint.y > 2){
          return;
        }
      }else{
        if(newPoint.y < 7 || newPoint.y > 9){
          return;
        }
      }

      // 目标位置是否有己方子
      if(map.hasChessAt(newPoint, team:item.team)){
        return;
      }
      points.add(newPoint.toCode());
    });
    return points;
  }

}