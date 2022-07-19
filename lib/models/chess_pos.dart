/// 位置
class ChessPos {
  int x;
  int y;
  ChessPos(this.x, this.y);

  ChessPos.tlOrigin(this.x, int y) : y = 9 - y;

  ChessPos.fromCode(String code)
      : x = code.codeUnitAt(0) - 'a'.codeUnitAt(0),
        y = int.tryParse(code[1]) ?? 0;

  @override
  int get hashCode => x * 10 + y;

  String toCode() {
    return String.fromCharCode(x + 'a'.codeUnitAt(0)) + y.toString();
  }

  ChessPos copy() {
    return ChessPos(x, y);
  }

  @override
  String toString() => '$x.$y;${toCode()}';

  @override
  operator ==(Object other) {
    if (other is ChessPos) {
      return x == other.x && y == other.y;
    }
    return false;
  }
}
