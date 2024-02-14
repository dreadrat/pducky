import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'package:flame/events.dart';

import 'package:flame/game.dart';
import 'package:pducky/game/game.dart';

class PauseButtonComponent extends PositionComponent
    with HasGameRef<Pducky>, TapCallbacks {
  late final TextComponent text;

  PauseButtonComponent() {
    add(RectangleHitbox());
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
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    position.setValues(gameRef.size.x / 2, 80);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Set the text to "Pause" or "Resume" based on the game state
    text.text = gameRef.paused ? 'Resume' : 'Pause';
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Toggle the paused state of the game when the button is tapped
    print('Pause Tapped');
    gameRef.paused = !gameRef.paused;
  }
}
