import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/foundation.dart';

enum ButtonSide { Left, Right }

enum ButtonImage { Puppy, Duck, Minus, Plus }

class GameButton extends PositionedEntity with HasGameRef, TapCallbacks {
  final ButtonSide side;
  final ButtonImage image;
  final VoidCallback onTap;

  GameButton({
    required super.position,
    required this.side,
    required this.image,
    required this.onTap,
  }) : super(
          anchor: Anchor.center,
          size: Vector2.all(0),
          behaviors: [],
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

    // Initialize and add the sprite component
    _spriteComponent = SpriteComponent(
      sprite: sprite,
      size: size,
    );
    await add(_spriteComponent);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap();
    add(SequenceEffect([
      ScaleEffect.by(
        Vector2.all(1.5),
        EffectController(
          duration: 0.1,
          alternate: true,
        ),
      ),
    ]));
  }

  @override
  void onTapUp(TapUpEvent event) {
    // No action needed on tap up
  }
}
