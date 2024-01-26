import 'behaviors.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

class GameSpeedBehaviour extends Behavior {

  void speedUpGame(BouncingBehaviour bouncingBehaviour) {
    bouncingBehaviour.timeToBounce = bouncingBehaviour.timeToBounce - 200; // Change the timeToBounce
  }

  void slowDownGame(BouncingBehaviour bouncingBehaviour) {
    bouncingBehaviour.timeToBounce = bouncingBehaviour.timeToBounce + 200; // Change the timeToBounce
  }

  
}
