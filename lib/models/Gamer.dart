import 'hand.dart';

class Gamer{
  int curHand = 0;

  List<Hand> hands = [];

  Gamer(){
    hands.add(Hand('r'));
    hands.add(Hand('b'));
    curHand = 0;
  }

  switchPlayer(){
    curHand++;
    if(curHand >= hands.length){
      curHand = 0;
    }
    print('切换选手:${player.team}');
  }

  get player{
    return hands[curHand];
  }
}