
import 'chess_fen.dart';
import 'chess_item.dart';
import 'chess_pos.dart';

class ChessRule{

  ChessFen fen;

  ChessRule(this.fen);

  ChessRule.fromFen([String fenStr = ChessFen.initFen]){
    fen = ChessFen(fenStr);
  }

  /// 检查是否被将军
  bool checkCheckMate(team){

    return false;
  }

  /// 获取当前子力能移动的位置
  List<String> movePoints(ChessPos activePos){
    String code = fen[activePos.y][activePos.x];
    if(code.isEmpty || code =='0')return [];
    int team = code.codeUnitAt(0) < ChessFen.colIndexBase ? 0 : 1;
    code = code.toLowerCase();
    switch(code){
      case 'p':
        return moveP(team, code, activePos);
      case 'c':
        return moveC(team, code, activePos);
      case 'r':
        return moveR(team, code, activePos);
      case 'n':
        return moveN(team, code, activePos);
      case 'b':
        return moveB(team, code, activePos);
      case 'a':
        return moveA(team, code, activePos);
      case 'k':
        return moveK(team, code, activePos);
      default:
        return [];
    }
  }
  List<String> moveP(int team, String code, ChessPos activePos){
    List<String> points = [];

    [[1,0],[0,1],[-1,0],[0,-1]].forEach((m) {
      if(team == 0){
        // 不允许退
        if(m[1] < 0){
          return;
        }
        // 不过河不能横走
        if(activePos.y < 5 && m[0] != 0){
          return;
        }
      }else{
        // 不允许退
        if(m[1] > 0){
          return;
        }
        // 不过河不能横走
        if(activePos.y > 4 && m[0] != 0){
          return;
        }
      }
      ChessPos newPoint = ChessPos(activePos.x + m[0], activePos.y + m[1]);
      if(newPoint.x < 0 || newPoint.x > 8){
        return;
      }
      if(newPoint.y < 0 || newPoint.y > 9){
        return;
      }
      // 目标位置是否有己方子
      if(fen.hasItemAt(newPoint, team: team)){
        return;
      }
      points.add(newPoint.toCode());
    });
    return points;
  }
  List<String> moveC(int team,String code, ChessPos activePos){
    List<String> points = [];

    [[-1,0],[1,0],[0,-1],[0,1]].forEach((step) {
      bool hasRack = false;
      ChessPos movePoint = ChessPos(activePos.x + step[0], activePos.y + step[1]);

      while(movePoint.x >= 0 && movePoint.x <= 8 && movePoint.y >= 0 && movePoint.y <= 9){

        // 是否有炮架
        ChessItem current = ChessItem(fen.itemAtPos(movePoint));
        // print([movePoint, current]);
        if(!current.isBlank){
          // 遇到对方子就吃
          if(hasRack) {
            if (current.team != team) {
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
  List<String> moveR(int team,String code, ChessPos activePos){
    List<String> points = [];

    [[-1,0],[1,0],[0,-1],[0,1]].forEach((step) {
      ChessPos movePoint = ChessPos(activePos.x + step[0], activePos.y + step[1]);
      while(movePoint.x >= 0 && movePoint.x <= 8 && movePoint.y >= 0 && movePoint.y <= 9){

        // 遇到已方子立即停止
        ChessItem current = ChessItem(fen.itemAtPos(movePoint));
        if(!current.isBlank && current.team == team){
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
  List<String> moveN(int team,String code, ChessPos activePos){
    List<String> points = [];

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
      ChessPos newPoint = ChessPos(activePos.x + m[0], activePos.y + m[1]);
      if(newPoint.x < 0 || newPoint.x > 8){
        return;
      }
      if(newPoint.y < 0 || newPoint.y > 9){
        return;
      }
      // 是否别马腿
      if(fen.hasItemAt(ChessPos(activePos.x + m[0] ~/ 2, activePos.y + m[1] ~/ 2))){
        //print([newPoint, activePos.x + m[0] ~/ 2, activePos.y + m[1] ~/ 2]);
        return;
      }
      // 目标位置是否有己方子
      if(fen.hasItemAt(newPoint, team:team)){
        return;
      }
      points.add(newPoint.toCode());
    });
    return points;
  }
  List<String> moveB(int team,String code, ChessPos activePos){
    List<String> points = [];

    [[2,2],[-2,2],[-2,-2],[2,-2]].forEach((m) {
      ChessPos newPoint = ChessPos(activePos.x + m[0], activePos.y + m[1]);
      if(newPoint.x < 0 || newPoint.x > 8){
        return;
      }
      if(team == 0){
        if(newPoint.y < 0 || newPoint.y > 4){
          return;
        }
      }else{
        if(newPoint.y < 5 || newPoint.y > 9){
          return;
        }
      }
      // 是否别象腿
      if(fen.hasItemAt(ChessPos(activePos.x + m[0] ~/ 2, activePos.y + m[1] ~/ 2))){
        return;
      }
      // 目标位置是否有己方子
      if(fen.hasItemAt(newPoint, team:team)){
        return;
      }
      points.add(newPoint.toCode());
    });
    return points;
  }
  List<String> moveA(int team,String code, ChessPos activePos){
    List<String> points = [];

    [[1,1],[-1,1],[-1,-1],[1,-1]].forEach((m) {
      ChessPos newPoint = ChessPos(activePos.x + m[0], activePos.y + m[1]);
      if(newPoint.x < 3 || newPoint.x > 5){
        return;
      }
      if(team == 0){
        if(newPoint.y < 0 || newPoint.y > 2){
          return;
        }
      }else{
        if(newPoint.y < 7 || newPoint.y > 9){
          return;
        }
      }
      // 目标位置是否有己方子
      if(fen.hasItemAt(newPoint, team:team)){
        return;
      }
      points.add(newPoint.toCode());
    });
    return points;
  }
  List<String> moveK(int team,String code, ChessPos activePos){
    List<String> points = [];

    [[1,0],[0,1],[-1,0],[0,-1]].forEach((m) {
      ChessPos newPoint = ChessPos(activePos.x + m[0], activePos.y + m[1]);
      if(newPoint.x < 3 || newPoint.x > 5){
        return;
      }
      if(team == 0){
        if(newPoint.y < 0 || newPoint.y > 2){
          return;
        }
      }else{
        if(newPoint.y < 7 || newPoint.y > 9){
          return;
        }
      }

      // 目标位置是否有己方子
      if(fen.hasItemAt(newPoint, team:team)){
        return;
      }
      points.add(newPoint.toCode());
    });
    return points;
  }

}