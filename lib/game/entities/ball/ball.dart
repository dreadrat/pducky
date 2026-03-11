import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';
import 'package:pducky/game/cubit/cubit.dart';
import 'package:pducky/game/entities/ball/behaviors/behaviors.dart';
import 'package:pducky/game/entities/ball/behaviors/bouncing_behaviour.dart';

class Ball extends PositionedEntity with HasGameRef {
  Ball({
    required super.position,
    required this.scoringCubit,
    required this.sessionCubit,
  }) : super(
          anchor: Anchor.center,
          size: Vector2.all(0),
        ) {
    // Listen to the scoreIncreasedStream
    scoringCubit.scoreIncreasedStream.listen((_) {
      triggerScoreEffect();
    });

    // Listen to the SessionCubit state changes
    sessionCubit.stream.listen((state) {
      textComponent.text = state.currentWord;

      // Update the thought word list when the thought changes.
      final words = state.thought
          .split(RegExp(r'\s+'))
          .map((w) => w.trim())
          .where((w) => w.isNotEmpty)
          .toList();
      if (words.join(' ') != _thoughtWords.join(' ')) {
        _thoughtWords
          ..clear()
          ..addAll(words);
        _thoughtIndex = 0;
        _thoughtAccum = 0;
      }

      triggerTextEffect();
    });
  }
  late SpriteComponent _spriteComponent;
  String currentImage = (Random().nextBool() ? 'puppy.png' : 'duck.png');
  final ScoringCubit scoringCubit;
  final SessionCubit sessionCubit;
  late CircleComponent circle;
  late TextComponent textComponent;
  late TextComponent thoughtComponent;

  final _thoughtWords = <String>[];
  int _thoughtIndex = 0;
  double _thoughtAccum = 0;

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
        ..color = const Color.fromARGB(
            0, 170, 248, 1), // Make the circle bright yellow
    );

    add(circle);
    add(_spriteComponent);

    final hitbox = RectangleHitbox(size: size, anchor: Anchor.center);
    add(hitbox);

    add(
      BouncingBehaviour(
        onDirectionChange: (direction) async {
          final newImage =
              Random().nextBool() ? BallImage.Puppy : BallImage.Duck;
          final sprite = await gameRef.loadSprite(
            'assets/images/${newImage == BallImage.Puppy ? 'puppy.png' : 'duck.png'}',
          );
          _spriteComponent.sprite = sprite;
          scoringCubit.updateBallImage(newImage);
        },
        scoringCubit: scoringCubit,
      ),
    );

    textComponent = TextComponent(
      text: sessionCubit.state.currentWord,
      position: Vector2(size.x / 2, size.y + 10),
      anchor: Anchor.topCenter,
    );

    thoughtComponent = TextComponent(
      text: '',
      position: Vector2(size.x / 2, size.y + 28),
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFB0B0B0),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );

    add(textComponent);
    add(thoughtComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Show the thought word-by-word *between* guided lines (when not speaking).
    final inRound = sessionCubit.state.elapsedTime >= 60;
    final hasThought = _thoughtWords.isNotEmpty;
    final canShowThought =
        inRound && hasThought && sessionCubit.state.isSpeaking == false;

    if (!canShowThought) {
      thoughtComponent.text = '';
      _thoughtAccum = 0;
      return;
    }

    // Fade from 35% to 5% opacity over the round.
    final progress =
        ((sessionCubit.state.elapsedTime - 60) / (600 - 60)).clamp(0.0, 1.0);
    final opacity = (0.35 + (0.05 - 0.35) * progress).clamp(0.05, 0.35);
    thoughtComponent.textRenderer = TextPaint(
      style: TextStyle(
        color: const Color(0xFFB0B0B0).withValues(alpha: opacity),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );

    // Advance a thought word every ~0.9s.
    _thoughtAccum += dt;
    if (thoughtComponent.text.isEmpty || _thoughtAccum >= 0.9) {
      _thoughtAccum = 0;
      thoughtComponent.text = _thoughtWords[_thoughtIndex];
      _thoughtIndex = (_thoughtIndex + 1) % _thoughtWords.length;
    }
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

  void triggerTextEffect() {
    final textIntroEffectController = EffectController(
      duration: 0.5,
      curve: Curves.easeInOut,
    );
    // Create a ScaleEffect that doubles the size of the text
    final scaleEffect = ScaleEffect.by(
      Vector2.all(2), textIntroEffectController, // Set duration directly
    );

    // Add the effects to the textComponent
    textComponent.add(scaleEffect);
  }
}
