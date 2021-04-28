

import 'chess_pos.dart';

class ChessFen{
  static const initFen = 'rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR';
  static int colIndexBase = 'a'.codeUnitAt(0);

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

  String _fen = '';
  List<ChessFenRow> _rows;

  ChessFen([String fenStr = initFen]){
    if(fenStr.isEmpty){
      fenStr = initFen;
    }
    this.fen = fenStr;
  }

  ChessFenRow operator [](int key){
    return _rows[key];
  }

  operator []=(int key, ChessFenRow value){
    _rows[key] = value;
  }

  String get fen{
    if(_fen.isEmpty){
      _fen = _rows.reversed.join('/')
          .replaceAllMapped(RegExp(r'0+'), (match) => match[0].length.toString());
    }
    return _fen;
  }

  set fen(String fenStr){
    this._rows = fenStr.replaceAllMapped(RegExp(r'\d'),
            (match) => List<String>.filled(int.parse(match[0]), '0').join('')
    ).split('/').reversed
        .map<ChessFenRow>((row) => ChessFenRow(row)).toList();
  }

  move(String move){
    int fromX = move.codeUnitAt(0) - colIndexBase;
    int fromY = int.parse(move[1]);
    int toX = move.codeUnitAt(2) - colIndexBase;
    int toY = int.parse(move[3]);
    _rows[fromY][fromX] = _rows[toY][toX];
    _rows[toY][toX] = '0';
    _fen = '';
  }

  String itemAt(String pos){
    int x = pos.codeUnitAt(0) - colIndexBase;
    int y = int.parse(pos[1]);
    return _rows[y][x];
  }

  List<ChessPos> findAll(String matchCode){
    List<ChessPos> items = [];
    int rowNumber = 0;
    _rows.forEach((row) {
      int start = row.indexOf(matchCode);
      while(start > -1){
        items.add(ChessPos(start, rowNumber));

        start = row.indexOf(matchCode, start + 1);
      }

      rowNumber++;
    });
    return items;
  }

  List<String> colItems(int colIndex){

  }
  List<String> rowItems(int colIndex){

  }

  @override
  String toString() {
    return fen;
  }

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

  String toPositionString(int team, String move){

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

    List<ChessPos> items = findAll(matchCode);

    ChessPos curItem;
    // 这种情况只能是小兵
    if(nameIndex.contains(move[0])){

      // 筛选出有同列的兵
      List<ChessPos> nItems = items.where((item) => items.any((pawn) => pawn != item && pawn.x == item.x) ).toList();
      nItems.sort(posSort);
      colIndex = nameIndex.indexOf(move[0]);
      curItem = team == 0 ? nItems[nItems.length - colIndex - 1] : nItems[colIndex];
      // 前中后
    }else if(posIndex.contains(move[0])){

      // 筛选出有同列的兵
      List<ChessPos> nItems = items.where((item) => items.any((pawn) => pawn != item && pawn.x == item.x) ).toList();
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

      List<ChessPos> nItems = items.where((item) => item.x == colIndex ).toList();
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

    ChessPos nextItem = ChessPos(0, 0);
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

  String toChineseString(String move){
    String _chineseString;

    ChessPos posFrom = ChessPos.fromCode(move.substring(0,2));
    ChessPos posTo = ChessPos.fromCode(move.substring(2,4));

    // 找出子
    String matchCode = _rows[posFrom.y][posFrom.x];
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

      _rows.forEach((row) {
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
        List<ChessPos> pawns = findAll(matchCode);

        // 筛选出有同列的兵
        List<ChessPos> nPawns = pawns.where((item) =>
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

class ChessFenRow{
  String fenRow;

  ChessFenRow(this.fenRow);

  String operator [](int key){
    return fenRow[key];
  }

  operator []=(int key, String value){
    fenRow = fenRow.replaceRange(key, key+1, value);
  }

  int indexOf(String matchCode, [int start = 0]){
    return fenRow.indexOf(matchCode, start);
  }

  @override
  String toString() {
    return fenRow;
  }
}