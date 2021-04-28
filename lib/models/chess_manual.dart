

import 'package:chinese_chess/models/chess_fen.dart';

import 'chess_step.dart';

class ChessManual{
  static const startFen = ChessFen.initFen + ' w - - 0 1';

  // 游戏类型
  String game = 'Chinese Chess';

  // 比赛名
  String event;
  // EventDate、EventSponsor、Section、Stage、Board、Time

  // 比赛地点
  String site;

  // 比赛日期，格式统一为“yyyy.mm.dd”
  String date;

  // 比赛轮次
  String round;

  // 红方棋手
  String red;
  String redTeam;

  // RedTitle、RedElo、RedType

  // 别名
  get redNA{
    return redTeam;
  }
  set redNA(String value){
    redTeam = value;
  }

  // 黑方棋手
  String black;
  String blackTeam;

  // 比赛结果 1-0 0-1 1/2-1/2 *
  String result = '*';

  // 开局
  String opening = '';

  // 变例
  String variation = '';

  // 开局编号
  String ecco = '';

  // 开始局面
  String fen;
  ChessFen currentFen;

  // 记谱方法 Chinese(中文纵线格式)、WXF(WXF纵线格式)和ICCS(ICCS坐标格式)
  String format = 'Chinese';

  // 时限
  String timeControl = '';

  // 结论
  String termination = '';
  // Annotator、Mode、PlyCount

  // 着法
  List<ChessStep> moves = [];

  ChessManual({
    this.fen = startFen,
    this.red = 'Red',
    this.black = 'Black',
    this.redTeam = 'RedTeam',
    this.blackTeam = 'BlackTeam',
    this.event = '',
    this.site = '',
    this.date = '',
    this.round = '1',
    this.ecco = '',
    this.timeControl = '',
  }){
    this.currentFen = ChessFen(this.fen.split(' ')[0]);
  }

  ChessManual.load(content){
    int idx = 0;
    int step = 0;
    String line = '';
    String description = '';
    while(true){
      String chr = content[idx];
      switch(chr){
        case '[':
          int endIdx = content.indexOf(']', idx);
          if(endIdx > idx){
            line = content.substring(idx + 1, endIdx-1);
            List<String> parts = line.trim().split(RegExp(r'\s+'));
            String value = parts[1].trim();
            if(value[0] == '"'){
              int lastIndex = value.lastIndexOf('"');
              value = value.substring(1, lastIndex > 1 ? lastIndex - 1 : null);
            }
            switch(parts[0].toLowerCase()){
              case 'game':
                this.game = value;
                break;
              case 'event':
                this.event = value;
                break;
              case 'site':
                this.site = value;
                break;
              case 'date':
                this.date = value;
                break;
              case 'round':
                this.round = value;
                break;
              case 'red':
                this.red = value;
                break;
              case 'redteam':
                this.redTeam = value;
                break;
              case 'black':
                this.black = value;
                break;
              case 'blackteam':
                this.blackTeam = value;
                break;
              case 'result':
                this.result = value;
                break;
              case 'opening':
                this.opening = value;
                break;
              case 'variation':
                this.variation = value;
                break;
              case 'ecco':
                this.ecco = value;
                break;
              case 'fen':
                this.fen = value;
                this.currentFen = ChessFen(fen.split(' ')[0]);
                break;
              case 'format':
                this.format = value;
                break;
              case 'timecontrol':
                this.timeControl = value;
                break;
              case 'termination':
                this.termination = value;
                break;
            }
          }else{
            print('Analysis pgn failed at $idx');
            break;
          }
          line = '';
          idx = endIdx + 1;
          break;
        case '{':
          int endIdx = content.indexOf('}');
          description = content.substring(idx + 1, endIdx - 1);
          idx = endIdx + 1;
          break;
        case ' ':
        case '\t':
        case '\n':
        case '\r':
          if(line.isNotEmpty){
            if(line.endsWith('.')){
              step = int.tryParse(line.substring(0, line.length - 2)) ?? 0;
              line = '';
            }else{
              addMove(line, description: description);
              description = '';
            }
          }
          break;
          // 这几个当作结尾注释吧
        case '=':
          return;
        default:
          line += chr;
      }

      idx ++;
      if(idx >= content.length){
        if(line.isNotEmpty){
          addMove(line, description: description);
        }
        break;
      }
    }
  }

  loadHistory(int index){
    currentFen.fen = moves[index].fen;
    currentFen.move(moves[index].move);
  }

  addMove(String move, {String description, int step = -1}){
    if(['1-0', '0-1', '1/2-1/2', '*'].contains(move)){
      result = move;
    }else {
      if(step > -1){
        moves = moves.take(step);
      }
      int team = moves.length % 2;

      // todo 自动解析所有格式
      if(isChineseMove(move)) {
        move = currentFen.toPositionString(team, move);
      }

      moves.add(ChessStep(team, '', move, description:description, round: (moves.length ~/ 2) + 1, fen: currentFen.toString()));

      currentFen.move(move);
    }
  }

  isNumberMove(String move){
    return RegExp(r'[abcrnkpABCRNKP][0-9a-e][+\-\.][0-9]').hasMatch(move);
  }
  isPosMove(String move){
    return RegExp(r'[a-iA-I][0-9]-?[a-iA-I][0-9]').hasMatch(move);
  }
  isChineseMove(String move){
    return !isNumberMove(move) && !isPosMove(move);
  }

}