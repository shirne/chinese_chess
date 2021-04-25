
class ChessStep{
  String code;
  String move;
  bool isEat = false;

  ChessStep(code, move, {isEat = false}){
    this.code = code;
    this.move = move;
    this.isEat = isEat;
  }


  @override
  String toString() {
    return '$code $move '+(isEat?'吃':'');
  }
}