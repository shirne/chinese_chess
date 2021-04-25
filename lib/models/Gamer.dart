import 'chess_rule.dart';
import 'engine.dart';
import 'hand.dart';

class Gamer{
  int curHand = 0;

  Engine engine;

  List<Hand> hands = [];

  ChessRule rule;

  Gamer(){
    rule = ChessRule();
    hands.add(Hand('r'));
    hands.add(Hand('b'));
    curHand = 0;
    engine = Engine();
    engine.init().then((process){
      engine.onMessage((message){
        print(message);
      });
    });
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