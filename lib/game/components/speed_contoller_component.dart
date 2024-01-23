import 'package:flame/components.dart';
import 'package:pducky/game/entities/puppyduck/behaviors/bouncing_behaviour.dart';
import 'package:pducky/game/components/button_component.dart';

class SpeedController extends PositionComponent with HasGameRef {
  late BouncingBehaviour bouncingBehaviour;

  SpeedController({
    required this.bouncingBehaviour,
  });

  @override
  Future<void> onLoad() async {
    // Set the size and position of the SpeedController
    size.setValues(gameRef.size.x * 0.2, gameRef.size.y * 0.1);
    position = Vector2(gameRef.size.x / 2 - size.x / 2, gameRef.size.y * 0.9);

    // Add the plus and minus buttons
    await add(GameButton(
      position: Vector2
          .zero(), // This will be overridden in the GameButton's onLoad method
      side: ButtonSide.Left,
      image: ButtonImage.Plus,
      onTap: bouncingBehaviour.speedUp,
    ));
    await add(GameButton(
      position: Vector2
          .zero(), // This will be overridden in the GameButton's onLoad method
      side: ButtonSide.Right,
      image: ButtonImage.Minus,
      onTap: bouncingBehaviour.slowDown,
    ));
  }
}
