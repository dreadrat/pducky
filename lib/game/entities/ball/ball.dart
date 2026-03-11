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
  final _thoughtWords = <String>[];
  int _thoughtIndex = 0;
  double _thoughtAccum = 0;
  double _thoughtOpacity = 0.0;

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

    // textComponent is used for BOTH guided words and thought words.
    add(textComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);

    final state = sessionCubit.state;

    // Guided round timing baseline.
    final roundStart = state.roundStartSeconds;
    final inRound = state.elapsedTime >= roundStart;

    // Fade target from 35% to 5% over 10 minutes of round time.
    // (If skipping intro, roundStart is 0; otherwise 60.)
    final roundElapsed = (state.elapsedTime - roundStart).clamp(0.0, 600.0);
    final progress = (roundElapsed / 600.0).clamp(0.0, 1.0);
    final fadeTarget = (0.35 + (0.05 - 0.35) * progress).clamp(0.05, 0.35);

    // Between sentences: show thought one word at a time.
    final showThought = inRound && _thoughtWords.isNotEmpty && !state.isSpeaking;

    if (showThought) {
      // Fade thought in.
      _thoughtOpacity = (_thoughtOpacity + dt * 1.5).clamp(0.0, fadeTarget);

      // Advance a thought word every ~0.9s.
      _thoughtAccum += dt;
      if (textComponent.text.isEmpty || _thoughtAccum >= 0.9) {
        _thoughtAccum = 0;
        textComponent.text = _thoughtWords[_thoughtIndex];
        _thoughtIndex = (_thoughtIndex + 1) % _thoughtWords.length;
      }

      textComponent.textRenderer = TextPaint(
        style: TextStyle(
          color: const Color(0xFFB0B0B0).withValues(alpha: _thoughtOpacity),
          fontSize: gameRef.size.y * 0.07,
          fontWeight: FontWeight.w500,
        ),
      );

      return;
    }

    // During guided sentences (or before round starts), fade thought out and let
    // SessionCubit / SpeechComponent drive the word.
    _thoughtOpacity = (_thoughtOpacity - dt * 2.0).clamp(0.0, 1.0);

    // Apply normal guided word style when speaking.
    if (state.isSpeaking) {
      textComponent.text = state.currentWord;
      textComponent.textRenderer = TextPaint(
        style: TextStyle(
          color: const Color(0xFFDEDADE).withValues(alpha: 1.0),
          fontSize: gameRef.size.y * 0.08,
          fontWeight: FontWeight.w600,
        ),
      );
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
