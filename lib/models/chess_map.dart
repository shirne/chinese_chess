

class ChessMap {
  List<List<ChessItem>> mapData = [];

  ChessMap(){
    this.clear();
  }

  ChessMap.fromFen(String fen){
    if(fen.isNotEmpty){
      load(fen);
    }
  }

  load(String fen){
    List<String> sets = fen.split(' ');
    List<String> rows = sets[0].split('/');
    int y = 9;
    int x = 0;
    this.clear();
    rows.forEach((row) {
      row.split('').forEach( ( chr ){
        if ('abcrnkp'.indexOf(chr) > -1) {
          mapData[y][x] = ChessItem(team: 'b', code: chr.toLowerCase(), x:x, y:y);
        }else if ('ABCRNKP'.indexOf(chr) > -1) {
          mapData[y][x] = ChessItem(team: 'r', code: chr.toLowerCase(), x:x, y:y);
        }else if('123456789'.indexOf(chr) > -1){
          int blank = int.parse(chr);
          x += blank - 1;
        }
        x++;
      });
      y --;
      x = 0;
    });
    // print(mapData);
  }

  operator [](XYKey key){
    return mapData[key.y][key.x];
  }

  operator []=(XYKey key, ChessItem value){
    mapData[key.y][key.x] = value;
  }

  clear(){
    mapData = List.generate(10, ( y ) => List.generate(9,(x) => ChessItem(isBlank: true, x:x, y:y)));
  }

  String toFen(){
    List<String> fens = [];
    mapData.forEach((element) {
      List<String> row = [];
      int lastBlank = 0;
      element.forEach((item) {
        if(item.isBlank){
          lastBlank += 1;
        }else{
          if(lastBlank > 0){
            row.add(lastBlank.toString());
            lastBlank = 0;
          }
          row.add(item.team == 'r'?item.code.toUpperCase():item.code);
        }
      });
      if(lastBlank > 0){
        row.add(lastBlank.toString());
      }

      fens.add(row.join(''));
    });
    return fens.reversed.join('/');
  }

  hasChessAt(XYKey point, {String team = ''}){
    if(!mapData[point.y][point.x].isBlank){
      if(team.isEmpty || team == mapData[point.y][point.x].team){
        return true;
      }
    }
    return false;
  }
  getChessAt(XYKey point){
    return mapData[point.y][point.x];
  }

  _move(XYKey idxFrom, XYKey idxTo){
    if(idxFrom.x < 0 || idxTo.x < 0 ||
        idxFrom.y < 0 || idxTo.y < 0 ||
        idxFrom.x > 8 || idxTo.x > 8 ||
        idxFrom.y > 9 || idxTo.y > 9
    ) {
      print(['_move error', idxFrom, idxTo]);
      return;
    }
    if(idxFrom == idxTo){
      print(['_move same', idxFrom, idxTo]);
      return;
    }

    ChessItem swap = mapData[idxTo.y][idxTo.x];
    mapData[idxTo.y][idxTo.x] = mapData[idxFrom.y][idxFrom.x];
    mapData[idxTo.y][idxTo.x].position = idxTo.toCode();

    swap.isBlank = true;
    mapData[idxFrom.y][idxFrom.x] = swap;
    mapData[idxFrom.y][idxFrom.x].position = idxFrom.toCode();
  }

  moveByCode(String code){
    XYKey fromKey = XYKey.fromCode(code.substring(0, 2));
    XYKey toKey = XYKey.fromCode(code.substring(2, 4));
    _move(fromKey, toKey);
  }

  move(ChessItem piece, ChessItem blank){
    _move(XYKey(piece.x, piece.y), XYKey(blank.x, blank.y));
  }

  eat(ChessItem piece,ChessItem piece2){
    _move(XYKey(piece.x, piece.y), XYKey(piece2.x, piece2.y));
  }

  forEach(void f(XYKey key,ChessItem item)){
    for(int y = 0;y < mapData.length; y++){
      for(int x = 0; x < mapData[y].length; x++){
        f(XYKey(x, y), mapData[y][x]);
      }
    }
  }
}

class XYKey {
  int x;
  int y;
  XYKey(this.x, this.y);

  XYKey.tlOrigin(int x, int y){
    this.x = x;
    this.y = 9 - y;
  }

  XYKey.fromCode(String code){
    x = code.codeUnitAt(0) - 'a'.codeUnitAt(0);
    y = int.tryParse(code[1]) ?? 0;
  }

  @override
  int get hashCode => this.x * 10 + this.y;

  String toCode(){
    return String.fromCharCode(x + 'a'.codeUnitAt(0))+y.toString();
  }

  String toString(){
    return 'x: $x, y: $y; '+toCode();
  }

  operator ==(Object other){
    if(other is XYKey) {
      return this.x == other.x && this.y == other.y;
    }
    return false;
  }
}

class ChessItem{
  static int globalCode = 100;
  String position = 'a0';
  bool isBlank = true;
  String team = '';
  String code = '';
  int itemCode = 0;

  ChessItem({team = '',code = '',isBlank = false,position = '',x = -1,y = -1}){
    this.itemCode = globalCode++;
    this.team = team;
    this.code = code;
    this.isBlank = isBlank;
    if(position.isNotEmpty) {
      this.position = position;
    }else if(x > -1 && y > -1) {
      this.position = 'abcdefghi'[x]+y.toString();
    }
  }

  operator ==(Object other){
    if(other is ChessItem){
      return this.itemCode == other.itemCode;
    }
    return false;
  }

  int get x{
    return position.codeUnitAt(0) - 'a'.codeUnitAt(0);
  }
  int get y{
    return int.parse(position[1]);
  }

  String toString(){
    if(this.isBlank){
      return 'ChessItem $x $y $position blank#$itemCode';
    }
    return 'ChessItem $x $y $position $team$code#$itemCode';
  }

  @override
  int get hashCode => this.itemCode;
}