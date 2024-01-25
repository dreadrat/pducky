import 'package:flame/components.dart';
import 'package:pducky/game/components/button_component.dart';

class GameplayButtons extends Component with HasGameRef {
  @override
  Future<void> onLoad() async {
    await addAll([
      GameButton(
        position: Vector2.zero(),
        side: ButtonSide.Left,
        image: ButtonImage.Puppy,
        onTap: () {},
      ),
      GameButton(
        position: Vector2.zero(),
        side: ButtonSide.Left,
        image: ButtonImage.Duck,
        onTap: () {},
      ),
      GameButton(
        position: Vector2.zero(),
        side: ButtonSide.Right,
        image: ButtonImage.Duck,
        onTap: () {},
      ),
      GameButton(
        position: Vector2.zero(),
        side: ButtonSide.Right,
        image: ButtonImage.Puppy,
        onTap: () {},
      ),
    ]);
  }
}