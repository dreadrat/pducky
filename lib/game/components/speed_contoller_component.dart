import 'package:flame/components.dart';
import 'package:pducky/game/entities/ball/behaviors/bouncing_behaviour.dart';
import 'package:pducky/game/components/button_component.dart';

class SpeedController extends PositionComponent with HasGameRef {
  final BouncingBehaviour bouncingBehaviour;

  SpeedController({
    required this.bouncingBehaviour,
  });

  @override
  Future<void> onLoad() async {
    // Set the size and position of the SpeedController
    size.setValues(gameRef.size.x * 0.2, gameRef.size.y * 0.1);
    position = Vector2(gameRef.size.x / 2 - size.x / 2, gameRef.size.y * 0.9);

    
  }
}
