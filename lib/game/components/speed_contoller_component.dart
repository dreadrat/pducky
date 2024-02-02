import 'package:flame/components.dart';
import 'package:pducky/game/entities/ball/behaviors/bouncing_behaviour.dart';
import 'package:pducky/game/components/button_component.dart';
import 'package:flame/game.dart';

class SpeedController extends PositionComponent with HasGameRef {
  final BouncingBehaviour bouncingBehaviour;

  SpeedController({
    required this.bouncingBehaviour,
  });


  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Set the size and position of the SpeedController
    this.size.setValues(size.x * 0.2, size.y * 0.1);
    position = Vector2(size.x / 2 - this.size.x / 2, size.y * 0.9);
  }
  
}
