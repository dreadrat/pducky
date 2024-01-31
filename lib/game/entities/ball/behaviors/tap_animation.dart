import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

class TapAnimation extends PositionComponent with HasGameRef, TapCallbacks {
  @override
  void onTapDown(TapDownEvent event) {
    // Do something on tap down update event.

    add(SequenceEffect([
      ScaleEffect.by(
        Vector2.all(1.5),
        EffectController(
          duration: 0.2,
          alternate: true,
        ),
      ),
      RemoveEffect(),
    ]));
  }
}
