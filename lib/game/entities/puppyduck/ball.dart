import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';
import 'package:pducky/game/entities/puppyduck/behaviors/bouncing_behaviour.dart';
import 'package:pducky/game/entities/puppyduck/behaviors/collision_behaviour.dart';
import 'package:pducky/gen/assets.gen.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame/geometry.dart';
import 'package:flame/collisions.dart'; // Import geometry for Collidable

class PuppyDuck extends PositionedEntity with HasGameRef {
  PuppyDuck({
    required super.position,
  }) : super(
          anchor: Anchor.center,
          size: Vector2.all(0),
          behaviors: [
            BouncingBehaviour(
              onDirectionChange: (direction) {
                if (direction == MovementDirection.Right) {
                  FlameAudio.play('blip_left.mp3');
                } else {
                  FlameAudio.play('blip_right.mp3');
                }
              },
            ),
          ],
        );

  @visibleForTesting
  PuppyDuck.test({
    required super.position,
    super.behaviors,
  }) : super(size: Vector2.all(500));

  late SpriteAnimationComponent _animationComponent;

  @visibleForTesting
  SpriteAnimationTicker get animationTicker =>
      _animationComponent.animationTicker!;

  @override
  Future<void> onLoad() async {
    // Set the size of the PuppyDuck to be 10% of the game height
    size.setValues(gameRef.size.y * 0.2, gameRef.size.y * 0.2);
    // Set the position of the PuppyDuck to be 1/3 from the top of the game
    position = Vector2(gameRef.size.x / 2, gameRef.size.y / 3);

    final animation = await gameRef.loadSpriteAnimation(
      Assets.images.unicornAnimation.path,
      SpriteAnimationData.sequenced(
        amount: 16,
        stepTime: 0.1,
        textureSize: Vector2.all(32),
        loop: false,
      ),
    );

    final hitbox = RectangleHitbox(size: size);
    add(hitbox);

    await add(
      _animationComponent = SpriteAnimationComponent(
        animation: animation,
        size: size,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
  }
}
