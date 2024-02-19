import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:pducky/game/game.dart';

class PauseButtonComponent extends PositionedEntity with HasGameRef<Pducky> {
  late TextComponent text;

  PauseButtonComponent() : super() {
    size = Vector2(100, 50);
    anchor = Anchor.center;
    add(PauseButtonBehavior(this));
  }

  @override
  Future<void> onLoad() async {
    await add(
      text = TextComponent(
        anchor: Anchor.center,
        textRenderer:
            TextPaint(style: gameRef.textStyle.copyWith(fontSize: 16)),
      ),
    );
    if (gameRef.paused) {
      text.text = 'Resume';
    } else {
      text.text = 'Pause';
    }

    text.position = size / 2;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    position.setValues(gameRef.size.x / 2, 80);
  }

  @override
  void update(double dt) {
    super.update(dt);
  }
  // Update the text based on the game state
}

class PauseButtonBehavior extends Behavior
    with TapCallbacks, HasGameRef<Pducky> {
  late PauseButtonComponent pauseButtonComponent;

  PauseButtonBehavior(this.pauseButtonComponent);

  @override
  void onTapDown(TapDownEvent event) {
    print('Pause Tapped');

    if (gameRef.paused) {
      gameRef.resumeEngine();
      pauseButtonComponent.text = TextComponent(text: 'Pause');
      print('Resumed');
    } else {
      gameRef.pauseEngine();
      pauseButtonComponent.text = TextComponent(text: 'Resume');
      print('Paused');
    }
  }
}
