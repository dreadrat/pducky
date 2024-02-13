import 'package:flame/components.dart';
import 'package:pducky/game/game.dart';

class StopwatchComponent extends PositionComponent with HasGameRef<Pducky> {
  late final TextComponent text;
  double elapsedTime = 0;

  @override
  Future<void> onLoad() async {
    position.setValues(gameRef.size.x / 2, 50);

    await add(
      text = TextComponent(
        anchor: Anchor.center,
        textRenderer:
            TextPaint(style: gameRef.textStyle.copyWith(fontSize: 20)),
      ),
    );
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    position.setValues(gameSize.x / 2, 50);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Increment the elapsed time if the game is not paused
    if (!gameRef.paused) {
      elapsedTime += dt;
    }

    // Round the elapsed time to the nearest second
    final roundedElapsedTime = elapsedTime.round();

    // Calculate minutes and seconds
    final minutes = (roundedElapsedTime / 60).floor();
    final remainingSeconds = roundedElapsedTime % 60;

    // Format the elapsed time as a stopwatch
    final stopwatchTime =
        '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';

    // Set the text to the stopwatch time
    text.text = stopwatchTime;
  }
}
