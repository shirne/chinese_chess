

import 'chess_map.dart';
import 'chess_step.dart';

class ChessManual{
  static const startFen = 'rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1';

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
  String opening;

  // 变例
  String variation;

  // 开局编号
  String ecco;

  // 开始局面
  String fen;
  String currentFen = '';

  // 记谱方法 Chinese(中文纵线格式)、WXF(WXF纵线格式)和ICCS(ICCS坐标格式)
  String format = 'Chinese';

  // 时限
  String timeControl;

  // 结论
  String termination;
  // Annotator、Mode、PlyCount

  List<ChessStep> moves;

  ChessManual();

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
                this.currentFen = fen.isEmpty ? startFen : fen;
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
              addMove(line, step: step, description: description);
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
          addMove(line, step: step, description: description);
        }
        break;
      }
    }
  }

  addMove(String move, {String description, int step = 0}){
    if(['1-0', '0-1', '1/2-1/2', '*'].contains(move)){
      result = move;
    }else {
      int team = moves.length % 2;
      move = parseMove(team, move);

      moves.add(ChessStep(team, '', move, description:description, round: step, fen: currentFen));

      currentFen = moveFen(currentFen, move);
    }
  }

  parseMove(int team, String move){
    return toPositionString(team, move, currentFen);
  }

  static const nameMap = {
    '将':'k',
    '帅':'K',
    '士':'a',
    '仕':'A',
    '象':'b',
    '相':'B',
    '马':'n',
    '车':'r',
    '炮':'c',
    '砲':'C',
    '卒':'p',
    '兵':'P'
  };
  static const nameRedMap = {
    'k':'帅',
    'a':'仕',
    'b':'相',
    'n':'马',
    'r':'车',
    'c':'砲',
    'p':'兵',
  };
  static const nameBlackMap = {
    'k':'将',
    'a':'士',
    'b':'象',
    'n':'马',
    'r':'车',
    'c':'炮',
    'p':'卒',
  };
  static const colRed = ['九','八','七','六','五','四','三','二','一'];
  static const colBlack = ['1','2','3','4','5','6','7','8','9'];
  static const nameIndex = ['一','二','三','四','五'];
  static const stepIndex = ['','一','二','三','四','五','六','七','八','九'];
  static const posIndex = ['前','中','后'];

  static int posSort(key1, key2){
    if(key1.x > key2.x){
      return -1;
    }else if(key1.x < key2.x){
      return 1;
    }
    if(key1.y > key2.y){
      return -1;
    }else if(key1.y < key2.y){
      return 1;
    }
    return 0;
  }

  static moveFen(String fen, String move){
    List<String> fenParts = fen.split(' ');
    List<String> fenRows = fenParts[0]
        .replaceAllMapped(RegExp(r'\d'),
            (match) => List<String>.filled(int.parse(match[0]), '0').join('')
    ).split('/').reversed.toList();

    XYKey posFrom = XYKey.fromCode(move.substring(0,2));
    XYKey posTo = XYKey.fromCode(move.substring(2,4));

    fenRows[posTo.y] = fenRows[posTo.y].replaceRange(posTo.x, posTo.x + 1, fenRows[posFrom.y][posFrom.x]) ;

    fenRows[posFrom.y] = fenRows[posFrom.y].replaceRange(posFrom.x, posFrom.x + 1, '0');

    fenParts[0] = fenRows.reversed.join('/').replaceAllMapped(RegExp(r'0+'), (match) => match[0].length.toString());

    return fenParts.join(' ');
  }

  static toPositionString(int team, String move, String fen){
    List<String> fenParts = fen.split(' ');
    List<String> fenRows = fenParts[0]
        .replaceAllMapped(RegExp(r'\d'),
            (match) => List<String>.filled(int.parse(match[0]), '0').join('')
    ).split('/').reversed.toList();

    String code;
    String matchCode;
    int colIndex = -1;

    if(nameIndex.contains(move[0]) || posIndex.contains(move[0])){
      code = nameMap[move[1]];
    }else{
      code = nameMap[move[0]];
      colIndex = team == 0 ? colRed.indexOf(move[1]) : colBlack.indexOf(move[1]);
    }
    code = code.toLowerCase();
    matchCode = team == 0 ? code.toUpperCase() : code;

    List<XYKey> items = [];
    int rowNumber = 0;
    fenRows.forEach((row) {
      int start = row.indexOf(matchCode);
      while(start > -1){
        items.add(XYKey(start, rowNumber));

        start = row.indexOf(matchCode, start+1);
      }

      rowNumber++;
    });

    XYKey curItem;
    // 这种情况只能是小兵
    if(nameIndex.contains(move[0])){

      // 筛选出有同列的兵
      List<XYKey> nItems = items.where((item) => items.any((pawn) => pawn != item && pawn.x == item.x) ).toList();
      nItems.sort(posSort);
      colIndex = nameIndex.indexOf(move[0]);
      curItem = team == 0 ? nItems[nItems.length - colIndex - 1] : nItems[colIndex];
      // 前中后
    }else if(posIndex.contains(move[0])){

      // 筛选出有同列的兵
      List<XYKey> nItems = items.where((item) => items.any((pawn) => pawn != item && pawn.x == item.x) ).toList();
      nItems.sort(posSort);
      if(nItems.length > 2){
        colIndex = posIndex.indexOf(move[0]);
        curItem = team == 0 ? nItems[nItems.length - colIndex - 1] : nItems[colIndex];
      }else{
        if( (team == 0 && move[0] == '前') || (team == 1 && move[0] == '后')){
          curItem = nItems[1];
        }else{
          curItem = nItems[0];
        }
      }
    }else{
      colIndex = team == 0 ? colRed.indexOf(move[1]) : colBlack.indexOf(move[1]);

      List<XYKey> nItems = items.where((item) => item.x == colIndex ).toList();
      nItems.sort(posSort);
      if(nItems.length > 1){
        if((team == 0 && move[2] == '进') || (team == 1 && move[2] == '退')){
          curItem = nItems[1];
        }else{
          curItem = nItems[0];
        }
      }else{
        curItem = nItems[0];
      }
    }

    XYKey nextItem = XYKey(0, 0);
    if(['p','k','c','r'].contains(code)){
      if(move[2] == '平'){
        nextItem.y = curItem.y;
        nextItem.x = team == 0 ? colRed.indexOf(move[3]) : colBlack.indexOf(move[3]);
      }else if( (team == 0 && move[2] == '进') || (team == 1 && move[2] == '退')){
        nextItem.x = curItem.x;
        nextItem.y = curItem.y + (team == 0 ? stepIndex.indexOf(move[3]) : int.parse(move[3]));
      }else{
        nextItem.x = curItem.x;
        nextItem.y = curItem.y - (team == 0 ? stepIndex.indexOf(move[3]) : int.parse(move[3]));
      }
    }else{
      nextItem.x = team == 0 ? colRed.indexOf(move[3]) : colBlack.indexOf(move[3]);
      if( (team == 0 && move[2] == '进' ) || (team == 1 && move[2] == '退' )){
        if(code == 'n'){
          if( (nextItem.x - curItem.x).abs() == 2 ){
            nextItem.y = curItem.y + 1;
          }else{
            nextItem.y = curItem.y + 2;
          }
        }else{
          nextItem.y = curItem.y + (nextItem.x - curItem.x).abs();
        }
      }else{
        if(code == 'n'){
          if( (nextItem.x - curItem.x).abs() == 2 ){
            nextItem.y = curItem.y - 1;
          }else{
            nextItem.y = curItem.y - 2;
          }
        }else{
          nextItem.y = curItem.y - (nextItem.x - curItem.x).abs();
        }
      }
    }


    return '${curItem.toCode()}${nextItem.toCode()}';
  }

  static toChineseString(String move, String fen){
    String _chineseString;
    List<String> fenParts = fen.split(' ');
    List<String> fenRows = fenParts[0]
        .replaceAllMapped(RegExp(r'\d'),
            (match) => List<String>.filled(int.parse(match[0]), '0').join('')
    ).split('/').reversed.toList();

    XYKey posFrom = XYKey.fromCode(move.substring(0,2));
    XYKey posTo = XYKey.fromCode(move.substring(2,4));

    // 找出子
    String matchCode = fenRows[posFrom.y][posFrom.x];
    int team = matchCode.codeUnitAt(0) < 'a'.codeUnitAt(0) ? 0 : 1;
    String code = matchCode.toLowerCase();

    // 子名
    String name = team == 0 ? nameRedMap[code] : nameBlackMap[code];

    if(code == 'k' || code == 'a' || code == 'b'){
      _chineseString = name + (team == 0 ? colRed[posFrom.x] : colBlack[posFrom.x]);

    }else{
      int colCount = 0;
      int rowNumber = 0;

      List<int> rowIndexs = [];

      fenRows.forEach((row) {
        if(row[posFrom.x] == matchCode){
          colCount++;

          rowIndexs.add(rowNumber);
        }
        rowNumber++;
      });
      if(colCount > 3) {
        int idx = rowIndexs.indexOf(posFrom.y);
        if(team == 0) {
          _chineseString = nameIndex[idx] + name;
        }else{
          _chineseString = nameIndex[rowIndexs.length - idx - 1] + name;
        }
      }else if(colCount > 2 || (colCount > 1 && code == 'p')){
        // 找出所有的兵
        List<XYKey> pawns = [];
        rowNumber = 0;
        fenRows.forEach((row) {
          int start = row.indexOf(matchCode);
          while(start > -1){
            pawns.add(XYKey(start, rowNumber));

            start = row.indexOf(matchCode, start+1);
          }

          rowNumber++;
        });

        // 筛选出有同列的兵
        List<XYKey> nPawns = pawns.where((item) =>
            pawns.any((pawn) =>
            (pawn != item && pawn.x == item.x)
          )
        ).toList();
        nPawns.sort(posSort);

        int idx = nPawns.indexOf(posFrom);
        if(team == 0) {
          _chineseString = nameIndex[idx] + name;
        }else{
          _chineseString = nameIndex[nPawns.length - idx - 1] + name;
        }
      }else if(colCount > 1){
        if(team == 0) {
          _chineseString = (posFrom.y > rowIndexs[1] ? '前' : '后') + name;
        }else{
          _chineseString = (posFrom.y < rowIndexs[0] ? '前' : '后') + name;
        }
      }else {
        _chineseString = name + (team == 0 ? colRed[posFrom.x] : colBlack[posFrom.x]);
      }
    }
    if(posFrom.y == posTo.y){
      _chineseString += '平'+(team == 0 ? colRed[posTo.x] : colBlack[posTo.x]);
    }else{
      if( (team == 0 && posFrom.y < posTo.y) || (team == 1 && posFrom.y > posTo.y)) {
        _chineseString += '进';
      }else{
        _chineseString += '退';
      }
      if(['p','k','c','r'].contains(code)){
        int step = (posFrom.y - posTo.y).abs();
        _chineseString += team == 0 ? stepIndex[step] : step.toString();
      }else{
        _chineseString += team == 0 ? colRed[posTo.x] : colBlack[posTo.x];
      }
    }

    return _chineseString;
  }
}