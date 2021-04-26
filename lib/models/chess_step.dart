
class ChessStep{
  int round = 0;
  String code;
  String move;
  String description;
  bool isEat = false;

  ChessStep(code, move, {description = '', isEat = false, round = 0}){
    this.code = code;
    this.move = move;
    this.isEat = isEat;
  }


  @override
  String toString() {
    return '$code $move '+(isEat?'吃':'');
  }
}