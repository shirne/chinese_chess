class ChessPos {
  int x;
  int y;
  ChessPos(this.x, this.y);

  ChessPos.tlOrigin(int x, int y){
    this.x = x;
    this.y = 9 - y;
  }

  ChessPos.fromCode(String code){
    x = code.codeUnitAt(0) - 'a'.codeUnitAt(0);
    y = int.tryParse(code[1]) ?? 0;
  }

  @override
  int get hashCode => this.x * 10 + this.y;

  String toCode(){
    return String.fromCharCode(x + 'a'.codeUnitAt(0))+y.toString();
  }

  String toString(){
    return '$x.$y;'+toCode();
  }

  operator ==(Object other){
    if(other is ChessPos) {
      return this.x == other.x && this.y == other.y;
    }
    return false;
  }
}