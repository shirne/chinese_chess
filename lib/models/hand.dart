


import 'chess_map.dart';

class Hand{
  ChessItem item;
  String lastPosition = '';
  String team = 'r';
  String title = '红方';

  int totalTime = 0;
  int stepTime = 0;

  Hand(this.team,{this.title});
}