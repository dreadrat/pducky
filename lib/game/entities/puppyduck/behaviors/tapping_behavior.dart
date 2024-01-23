import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:pducky/game/game.dart';
import 'package:pducky/gen/assets.gen.dart';

class TappingBehavior extends Behavior<PuppyDuck>
    with TapCallbacks, HasGameRef<Pducky> {
  @override
  bool containsLocalPoint(Vector2 point) {
    return parent.containsLocalPoint(point);
  }

 
}
