import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

enum ButtonSide { Left, Right }

enum ButtonImage { Puppy, Duck, Minus, Plus }

class GameButton extends PositionedEntity with HasGameRef, TapCallbacks {
  final ButtonSide side;
  final ButtonImage image;
  final VoidCallback onTap;
  double buttonScale = 1.0;
  bool hold = false; // Add this line

  GameButton({
    required super.position,
    required this.side,
    required this.image,
    required this.onTap,
  }) : super(
          anchor: Anchor.center,
          size: Vector2.all(0),
        );

  late SpriteComponent _spriteComponent;

  @override
  Future<void> onLoad() async {
    size.setValues(gameRef.size.y * 0.1, gameRef.size.y * 0.1);
    position = Vector2(
      side == ButtonSide.Left
          ? (image == ButtonImage.Puppy
              ? gameRef.size.x * 0.1
              : gameRef.size.x * 0.2)
          : (image == ButtonImage.Puppy
              ? gameRef.size.x * 0.9
              : gameRef.size.x * 0.8),
      image == ButtonImage.Puppy ? gameRef.size.y * 0.9 : gameRef.size.y * 0.75,
    );

    final sprite = await gameRef.loadSprite(
      'assets/images/${image == ButtonImage.Puppy ? 'puppy.png' : image == ButtonImage.Duck ? 'duck.png' : image == ButtonImage.Minus ? 'minus.png' : 'plus.png'}',
    );

    await add(
      _spriteComponent = SpriteComponent(
        sprite: sprite,
        size: size,
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (hold) {
      return;
    }
    hold = true;
    add(
      ScaleEffect.by(
        Vector2.all(0.9), // Scale down to 90% of the original size
        EffectController(duration: 0.3), // Duration of the effect
        onComplete: () => hold = false,
      ),
    );
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (hold) {
      return;
    }
    hold = true;
    add(
      ScaleEffect.by(
        Vector2.all(1 / 0.9), // Scale back to the original size
        EffectController(duration: 0.3), // Duration of the effect
        onComplete: () => hold = false,
      ),
    );
    onTap();
  }
}
