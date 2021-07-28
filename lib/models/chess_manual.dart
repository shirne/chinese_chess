

import 'chess_fen.dart';
import 'chess_item.dart';
import 'chess_pos.dart';
import 'chess_step.dart';

class ChessManual{
  static const startFen = ChessFen.initFen + ' w - - 0 1';
  static const resultFstWin = '1-0';
  static const resultFstLoose = '0-1';
  static const resultFstDraw = '1/2-1/2';
  static const resultUnknown = '*';
  static const results = [resultFstWin, resultFstLoose, resultFstDraw, resultUnknown];

  // 游戏类型
  String game = 'Chinese Chess';

  // 比赛名
  String event = '';
  // EventDate、EventSponsor、Section、Stage、Board、Time

  // 比赛地点
  String site = '';

  // 比赛日期，格式统一为“yyyy.mm.dd”
  String date = '';

  // 比赛轮次
  String round = '';

  // 红方棋手
  String red = '';
  String redTeam = '';

  // RedTitle、RedElo、RedType

  // 别名
  String get redNA{
    return redTeam;
  }
  set redNA(String value){
    redTeam = value;
  }

  // 黑方棋手
  String black = '';
  String blackTeam = '';

  // 比赛结果 1-0 0-1 1/2-1/2 *
  String result = '*';
  String get chineseResult{
    return ChessFen.getChineseResult(result);
  }

  // 开局
  String opening = '';

  // 变例
  String variation = '';

  // 开局编号
  String ecco = '';

  // 开始局面
  String fen = '';

  int startHand = 0;

  // 子力位置图
  late ChessFen fenPosition;

  // 当前
  late ChessFen currentFen;

  // 记谱方法 Chinese(中文纵线格式)、WXF(WXF纵线格式)和ICCS(ICCS坐标格式)
  String format = 'Chinese';

  // 时限
  String timeControl = '';

  // 结论
  String termination = '';
  // Annotator、Mode、PlyCount

  // 着法
  List<ChessStep> moves = [];
  int step = 0;

  ChessPos? diePosition;
  Map<String,ChessPos>? diePositions;

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
    initFen(this.fen);
  }

  initDefault(){
    fen = startFen;
    red = 'Red';
    black = 'Black';
    redTeam = 'RedTeam';
    blackTeam = 'BlackTeam';
    event = '';
    site = '';
    date = '';
    round = '1';
    ecco = '';
    timeControl = '';
    //currentFen = null;
    //fenPosition = null;
  }

  initFen(String fenStr){
    List<String> fenParts = fenStr.split(' ');
    this.currentFen = ChessFen(fenParts[0]);
    this.fenPosition = this.currentFen.position();
    if(fenParts.length > 1){
      if(fenParts[1] == 'b' || fenParts[1] == 'B'){
        startHand = 1;
      }else{
        startHand = 0;
      }
    }
    print('clear items');
    _items=[];
  }

  ChessManual.load(String content){
    int idx = 0;
    String line = '';
    String description = '';
    content = content.replaceAllMapped(
        RegExp('[${ChessFen.replaceNumber.join('')}]'),
            (match) => ChessFen.replaceNumber.indexOf(match[0]!).toString()
    );
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
                initFen(this.fen);
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
              // step = int.tryParse(line.substring(0, line.length - 2)) ?? 0;
              line = '';
            }else{
              addMove(line, description: description);
              description = '';
              line = '';
            }
          }
          break;
          // 这几个当作结尾注释吧
        case '=':
          return;
        default:
          line += chr;
          if(this.currentFen == null){
            if(fen == null || fen.isEmpty){
              fen = startFen;
            }
            initFen(fen);
          }
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

  String export(){
    List<String> lines = [];
    lines.add('[Game "$game"]');
    lines.add('[Event "$event"]');
    lines.add('[Round "$round"]');
    lines.add('[Date "$date"]');
    lines.add('[Site "$site"]');
    lines.add('[RedTeam "$redTeam"]');
    lines.add('[Red "$red"]');
    lines.add('[BlackTeam "$blackTeam"]');
    lines.add('[Black "$black"]');
    lines.add('[Result "$result"]');
    lines.add('[ECCO "$ecco"]');
    lines.add('[Opening "$opening"]');
    lines.add('[Variation "$variation"]');
    if(fen != startFen && fen != ChessFen.initFen){
      lines.add('[FEN "$fen"]');
    }

    for(int myStep = 0; myStep<moves.length; myStep += 2){
      lines.add('${(myStep ~/ 2) + 1}. ${moves[myStep].toChineseString()} '+(myStep < moves.length-1 ? moves[myStep+1].toChineseString() : result));
    }
    if(moves.length % 2 == 0){
      lines.add(result);
    }

    lines.add('=========================');
    lines.add('中国象棋 (https://www.shirne.com/demo/chinesechess/)');
    return lines.join("\n");
  }

  loadHistory(int index){
    if(index < 1){
      currentFen.fen = fen.split(' ')[0];
      fenPosition = currentFen.position();
    }else {
      currentFen.fen = moves[index-1].fen;
      fenPosition.fen = moves[index-1].fenPosition;
      doMove(moves[index-1].move);
    }
    step = index;
  }

  setFen(String fenStr){
    ChessFen startFen = ChessFen(fen);
    String initChrs = startFen.getAllChr();
    String initPositions = startFen.position().getAllChr();

    currentFen.fen = fenStr;
    fenPosition.fen = currentFen.fen.replaceAllMapped(
        RegExp(r'[^0-9\\/]'), (match){
          String chr = initPositions[initChrs.indexOf(match[0]!)];
          initChrs = initChrs.replaceFirst(match[0]!, '0');
          return chr;
        });
  }

  /// 设置某个位置，设置为空必真，设置为子会根据初始局面查找当前没在局面中的子的位置，未查找到会设置失败
  bool setItem(ChessPos pos, String chr){
    String posChr = '0';
    if(chr != '0'){
      ChessFen startFen = ChessFen(fen);
      String initChrs = startFen.getAllChr();
      String initPositions = startFen.position().getAllChr();

      String positions = fenPosition.getAllChr();

      int index = initChrs.indexOf(chr);
      while(index > -1){
        String curPosChr = initPositions[index];
        if(positions.indexOf(curPosChr) < 0){
          posChr = curPosChr;
          break;
        }
        index = initChrs.indexOf(chr, index+1);
      }
      if(posChr == '0'){
        return false;
      }
    }
    currentFen[pos.y][pos.x] = chr;
    fenPosition[pos.y][pos.x] = posChr;
    currentFen.clearFen();
    fenPosition.clearFen();
    _items = [];
    return true;
  }

  doMove(String move){
    currentFen.move(move);
    fenPosition.move(move);
  }

  bool get hasNext{
    return step < moves.length;
  }
  String next(){
    if(step < moves.length) {
      step++;
      String move = moves[step - 1].move;
      String result = currentFen.toChineseString(move);
      doMove(move);
      return result;
    }else{
      return ChessFen.getChineseResult(result);
    }
  }

  List<ChessItem> _items = [];
  List<ChessItem> getChessItems(){
    ChessFen startFen = ChessFen(fen);

    if(_items.length < 1) {
      _items = startFen.getAll();
    }

    // 初始位置编码
    String initPositions = startFen.position().getAllChr();
    // 当前位置编码
    String positions = fenPosition.getAllChr();
    int index = 0;

    _items.forEach((item) {
      // 当前子对应的初始序号
      String chr = initPositions[index];
      // 序号当前的位置
      int newIndex = positions.indexOf(chr);

      if(newIndex > -1){
        // print('${item.code}@${item.position.toCode()}: $chr @ $index => $newIndex');
        item.position = fenPosition.find(chr)!;
        item.isDie = false;
      }else{
        // print('${item.code}@${item.position.toCode()}: $chr @ $index --');
        if(diePositions != null && diePositions!.containsKey(item.code)){
          item.position = diePositions![item.code]!.copy();
        }else if(diePosition != null){
          item.position = diePosition!.copy();
        }
        item.isDie = true;
      }
      index++;
    });

    return _items;
  }

  // 获取当前招法
  ChessStep? getMove(){
    if(step < 1)return null;
    if(step > moves.length) return null;
    return moves[step-1];
  }

  clearMove([int fromStep = 0]){
    if(fromStep < 1) {
      moves.clear();
    }else{
      moves.removeRange(fromStep, moves.length);
    }
    print('Clear moves $fromStep $moves');
  }

  addMoves(List<String> moves){
    moves.forEach((move) {
      addMove(move);
    });
  }

  addMove(String move, {String description = '', int addStep = -1}){
    if(results.contains(move)){
      result = move;
    }else {
      if(addStep > -1){
        clearMove(addStep);
      }
      int team = moves.length % 2;

      // todo 自动解析所有格式
      if(isChineseMove(move)) {
        move = currentFen.toPositionString(team, move);
      }

      moves.add(ChessStep(
          team,
          move,
          code: currentFen.itemAt(move),
          description: description,
          round: (moves.length ~/ 2) + 1,
          fen: currentFen.fen,
          fenPosition: fenPosition.fen
      ));

      doMove(move);

      step = moves.length;
    }
  }

  int repeatRound(){
    int rewind = step - 1;
    int round = 0;

    while(rewind > 1){
      if(moves[rewind].fen == moves[rewind - 1].fen &&
          moves[rewind].move == moves[rewind - 1].move){
        round++;
      }else{
        break;
      }
      rewind -= 2;
    }
    return round;
  }

  static isNumberMove(String move){
    return RegExp(r'[abcrnkpABCRNKP][0-9a-e][+\-\.][0-9]').hasMatch(move);
  }
  static isPosMove(String move){
    return RegExp(r'[a-iA-I][0-9]-?[a-iA-I][0-9]').hasMatch(move);
  }
  static isChineseMove(String move){
    return !isNumberMove(move) && !isPosMove(move);
  }

}