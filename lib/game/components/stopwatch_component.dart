import 'package:flame/components.dart';
import 'package:pducky/game/game.dart';

class StopwatchComponent extends PositionComponent with HasGameRef<Pducky> {
  StopwatchComponent({
    required super.position,
  }) : super(anchor: Anchor.center);

  late final TextComponent text;
  late final PausePlayButton pauseButton;
  bool isPaused = false;

  @override
  Future<void> onLoad() async {
    position.setValues(gameRef.size.x / 2, 50); // Position at top center

    await add(
      text = TextComponent(
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: gameRef.textStyle.copyWith(fontSize: 20)
        ),
      ),
    );

    final playSprite = await gameRef.loadSprite('assets/images/play.png');
    final pauseSprite = await gameRef.loadSprite('assets/images/pause.png');

    pauseButton = PausePlayButton(
      onPressed: () {
       if (gameRef.paused) {
      gameRef.resumeEngine();
    } else {
      gameRef.pauseEngine();
    }
    pauseButton.setPaused(gameRef.paused);
      },
      playSprite: playSprite,
      pauseSprite: pauseSprite,
      position: Vector2(0, 50), 
      size: Vector2(20,20),
    );
    await add(pauseButton);
  }

    @override
  void update(double dt) {
    if (gameRef.paused) {
      return;
    }

    // Calculate the elapsed time in seconds
    final elapsedTime = DateTime.now().difference(gameRef.startTime);

    // Calculate minutes and seconds
    final minutes = elapsedTime.inMinutes;
    final seconds = elapsedTime.inSeconds % 60;

    // Format the elapsed time as a stopwatch
    final stopwatchTime =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    // Set the text to the stopwatch time
    text.text = stopwatchTime;
  }
}