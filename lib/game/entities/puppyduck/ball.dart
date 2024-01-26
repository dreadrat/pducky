import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';
import 'package:pducky/game/entities/puppyduck/behaviors/bouncing_behaviour.dart';
import 'package:pducky/gen/assets.gen.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame/collisions.dart';
import 'behaviors/behaviors.dart';
import 'dart:math';

class Ball extends PositionedEntity with HasGameRef {
  late SpriteComponent _spriteComponent;
  String currentImage = (Random().nextBool() ? 'puppy.png' : 'duck.png');

  Ball({
    required super.position,
  }) : super(
          anchor: Anchor.center,
          size: Vector2.all(0),
        );

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);

    size.setValues(gameSize.y * 0.1, gameSize.y * 0.1);
    position = Vector2(gameSize.x / 2, gameSize.y / 3);
  }

  @override
  Future<void> onLoad() async {
    size.setValues(gameRef.size.y * 0.1, gameRef.size.y * 0.1);
    position = Vector2(gameRef.size.x / 2, gameRef.size.y / 3);

    final sprite = await gameRef.loadSprite('assets/images/$currentImage');

    _spriteComponent = SpriteComponent(
      sprite: sprite,
      size: size,
    );

    add(_spriteComponent);

    final hitbox = RectangleHitbox(size: size);
    add(hitbox);

    add(BouncingBehaviour(
      onDirectionChange: (direction) async {
        String newImage = (Random().nextBool() ? 'puppy.png' : 'duck.png');
        ;
        final sprite = await gameRef.loadSprite('assets/images/$newImage');
        _spriteComponent.sprite = sprite;
      },
    ));
  }

  Future<void> playAudioBasedOnDirection(MovementDirection direction) async {
    if (direction == MovementDirection.Right) {
      await FlameAudio.play('blip_left.mp3');
    } else {
      await FlameAudio.play('blip_right.mp3');
    }
  }

  @visibleForTesting
  Ball.test({
    required super.position,
    super.behaviors,
  }) : super(size: Vector2.all(500));

  @override
  void update(double dt) {
    super.update(dt);
  }
}
