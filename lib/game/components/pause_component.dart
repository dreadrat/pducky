import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:pducky/game/components/button_component.dart';

class PauseButton extends GameButton {

  PauseButton({
    required Vector2 super.position,
    required super.side,
    required super.image,
    required super.onTap,
    required super.scoringCubit,
  });
  bool isPaused = false;

  @override
  Future<void> handleButtonPress() async {
    if (isPaused) {
      gameRef.resumeEngine();
      isPaused = false;
      spriteComponent.sprite =
          await gameRef.loadSprite('assets/images/pause.png');
    } else {
      gameRef.pauseEngine();
      isPaused = true;
      spriteComponent.sprite =
          await gameRef.loadSprite('assets/images/play.png');
    }
  }

  @override
  bool onTapDown(TapDownEvent event) {
    handleButtonPress();
    return false;
  }
}
