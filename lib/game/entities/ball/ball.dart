import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';
import 'package:flame/effects.dart';
import 'package:pducky/game/entities/ball/behaviors/bouncing_behaviour.dart';
import 'package:pducky/gen/assets.gen.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame/collisions.dart';
import 'behaviors/behaviors.dart';
import 'dart:math';
import 'package:pducky/game/cubit/cubit.dart';

class Ball extends PositionedEntity with HasGameRef {
  late SpriteComponent _spriteComponent;
  String currentImage = (Random().nextBool() ? 'puppy.png' : 'duck.png');
  final ScoringCubit scoringCubit;
  late CircleComponent circle;
  late TextComponent textComponent;

  Ball({
    required super.position,
    required this.scoringCubit,
  }) : super(
          anchor: Anchor.center,
          size: Vector2.all(0),
        ) {
    // Listen to the scoreIncreasedStream
    scoringCubit.scoreIncreasedStream.listen((_) {
      triggerScoreEffect();
    });
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size.setValues(gameSize.y * 0.08, gameSize.y * 0.08);
    position = Vector2(0, gameSize.y / 3);

    RectangleHitbox(size: size, anchor: Anchor.center);
  }

  @override
  Future<void> onLoad() async {
    size.setValues(gameRef.size.y * 0.08, gameRef.size.y * 0.08);

    final sprite = await gameRef.loadSprite('assets/images/$currentImage');

    _spriteComponent = SpriteComponent(
      sprite: sprite,
      size: size,
    );

    circle = CircleComponent(
      radius: gameRef.size.y * 0.05,
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2),
      // Start with a radius of 0
      paint: Paint()
        ..color =
            Color.fromARGB(0, 170, 248, 1), // Make the circle bright yellow
    );

    add(circle);
    add(_spriteComponent);

    final hitbox = RectangleHitbox(size: size, anchor: Anchor.center);
    add(hitbox);

    add(BouncingBehaviour(
      onDirectionChange: (direction) async {
        BallImage newImage =
            Random().nextBool() ? BallImage.Puppy : BallImage.Duck;
        ;
        final sprite = await gameRef.loadSprite(
            'assets/images/${newImage == BallImage.Puppy ? 'puppy.png' : 'duck.png'}');
        _spriteComponent.sprite = sprite;
        scoringCubit.updateBallImage(newImage);
      },
      scoringCubit: scoringCubit,
    ));

    textComponent = TextComponent(
      text: ' Here',
      position:
          Vector2(size.x / 2, size.y + 10), // Position the text under the ball
      anchor: Anchor.topCenter,
    );

    add(textComponent);
  }

  Future<void> playAudioBasedOnDirection(MovementDirection direction) async {
    if (direction == MovementDirection.Right) {
      await FlameAudio.play('blip_left.mp3');
    } else {
      await FlameAudio.play('blip_right.mp3');
    }
  }

  void triggerScoreEffect() {
    // Create a ScaleEffect that doubles the size of the circle

    final opacityEffect = OpacityEffect.to(
      1,
      EffectController(
        duration: 0.5,
        alternate: true,
      ),
    );

    // Add the effect to the circle with the controller

    circle.add(opacityEffect);
  }

  @override
  void update(double dt) {
    super.update(dt);
  }
}
