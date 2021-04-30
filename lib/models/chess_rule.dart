
import 'chess_fen.dart';
import 'chess_item.dart';
import 'chess_pos.dart';

class ChessRule{

  ChessFen fen;

  ChessRule(this.fen);

  ChessRule.fromFen([String fenStr = ChessFen.initFen]){
    fen = ChessFen(fenStr);
  }

  /// 是否困毙
  bool isTrapped(int team){
    List<ChessItem> pieces = fen.getAll();
    return !pieces.any((item) {
      if(item.team == team){
        List<String> points = movePoints(item.position);
        return points.any((point){
          ChessRule rule = ChessRule(fen.copy());
          rule.fen.move(item.position.toCode()+point);
          if(rule.isKingMeet(team)){
            return false;
          }
          if(rule.isCheckMate(team)){
            return false;
          }
          return true;
        });
      }
      return false;
    });
  }

  /// 是否可以解杀 [调用前确保正在被将]
  bool canParryKill(int team){
    ChessPos kPos = fen.find(team == 0 ? 'K' : 'k');
    if(kPos == null){
      // 老将没了
      return false;
    }

    List<ChessItem> pieces = fen.getAll();
    
    return pieces.any((item) {
      if(item.team == team){
        List<String> points = movePoints(item.position);
        return points.any((point){
          ChessRule rule = ChessRule(fen.copy());
          rule.fen.move(item.position.toCode()+point);
          if(rule.isKingMeet(team)){
            return false;
          }
          if(rule.isCheckMate(team)){
            return false;
          }
          return true;
        });
      }
      return false;
    });
  }

  /// 老将是否照面
  bool isKingMeet(int team){
    ChessPos kPos = fen.find(team == 0 ? 'K' : 'k');
    if(kPos == null){
      // 老将没了
      return true;
    }

    // 是否与对方老将同列，并且中间无子
    ChessPos enemyKing = fen.find(team == 0 ? 'k' : 'K');
    if(enemyKing != null && kPos.x == enemyKing.x){
      List<ChessItem> items = fen.findByCol(kPos.x);

      // 原则上没有小于2的情况，这里统一按照面计算
      if(items.length <= 2){
        return true;
      }
    }
    return false;
  }

  /// 检查是否被将军
  bool isCheckMate(int team){
    ChessPos kPos = fen.find(team == 0 ? 'K' : 'k');
    if(kPos == null){
      // 老将没了
      return true;
    }

    List<ChessItem> pieces = fen.getAll();

    return pieces.any((item) {
      if(item.team != team && !['K','k','A','a','B','b'].contains(item.code)){
        // 这里传入目标位置，返回的可行点有针对性
        List<String> points = movePoints(item.position, kPos);
        if(points.contains(kPos.toCode())){
          return true;
        }
      }
      return false;
    });
  }

  /// 检查被将军次数 todo 优化
  int checkCheckMate(int team){
    ChessPos kPos = fen.find(team == 0 ? 'K' : 'k');
    if(kPos == null){
      // 老将没了
      return 9999;
    }

    List<ChessItem> pieces = fen.getAll();
    int checkTime = 0;
    pieces.forEach((element) {
      if(element.team != team && !['K','k','A','a','B','b'].contains(element.code)){
        // 这里传入目标位置，返回的可行点有针对性
        List<String> points = movePoints(element.position, kPos);
        if(points.contains(kPos.toCode())){
          checkTime ++;
        }
      }
    });

    return checkTime;
  }

  /// 获取当前子力能移动的位置 target 为目标位置，如果传入了目标位置，则会优化检测
  List<String> movePoints(ChessPos activePos, [ChessPos target]){
    String code = fen[activePos.y][activePos.x];
    if(code.isEmpty || code =='0')return [];
    int team = code.codeUnitAt(0) < ChessFen.colIndexBase ? 0 : 1;
    code = code.toLowerCase();
    switch(code){
      case 'p':
        return moveP(team, code, activePos, target);
      case 'c':
        return moveC(team, code, activePos, target);
      case 'r':
        return moveR(team, code, activePos, target);
      case 'n':
        return moveN(team, code, activePos, target);
      case 'b':
        return moveB(team, code, activePos, target);
      case 'a':
        return moveA(team, code, activePos, target);
      case 'k':
        return moveK(team, code, activePos, target);
      default:
        return [];
    }
  }
  List<String> moveP(int team, String code, ChessPos activePos, [ChessPos target]){
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
      if(target != null && newPoint != target){
        return;
      }
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

  List<String> moveC(int team,String code, ChessPos activePos, [ChessPos target]){
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

  List<String> moveR(int team,String code, ChessPos activePos, [ChessPos target]){
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

  List<String> moveN(int team,String code, ChessPos activePos, [ChessPos target]){
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
      if(target != null && newPoint != target){
        return;
      }
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

  List<String> moveB(int team,String code, ChessPos activePos, [ChessPos target]){
    List<String> points = [];

    [[2,2],[-2,2],[-2,-2],[2,-2]].forEach((m) {
      ChessPos newPoint = ChessPos(activePos.x + m[0], activePos.y + m[1]);
      if(target != null && newPoint != target){
        return;
      }
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

  List<String> moveA(int team,String code, ChessPos activePos, [ChessPos target]){
    List<String> points = [];

    [[1,1],[-1,1],[-1,-1],[1,-1]].forEach((m) {
      ChessPos newPoint = ChessPos(activePos.x + m[0], activePos.y + m[1]);
      if(target != null && newPoint != target){
        return;
      }
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

  List<String> moveK(int team,String code, ChessPos activePos, [ChessPos target]){
    List<String> points = [];

    [[1,0],[0,1],[-1,0],[0,-1]].forEach((m) {
      ChessPos newPoint = ChessPos(activePos.x + m[0], activePos.y + m[1]);
      if(target != null && newPoint != target){
        return;
      }
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
      // 是否与对方老将同列，并且中间无子
      ChessPos enemyKing = fen.find(team == 0 ? 'k' : 'K');
      if(enemyKing != null && newPoint.x == enemyKing.x){
        List<ChessItem> items = fen.findByCol(newPoint.x);

        // 原则上没有小于1的情况，这里统一按只有对方老将一个
        if(items.length <= 1){
          return;
        }

        // 这里已经出错了
        if(items.length == 2 && activePos.x == enemyKing.x){
          return;
        }
      }

      points.add(newPoint.toCode());
    });
    return points;
  }

}