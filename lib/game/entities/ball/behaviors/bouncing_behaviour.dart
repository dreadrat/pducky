import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/widgets.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pducky/game/game.dart';
import 'package:pducky/game/cubit/cubit.dart';

enum MovementDirection { Left, Right }



class BouncingBehaviour extends Behavior with HasGameRef<Pducky> {
  int timeToBounce = 2000;
  late EffectController controller;
  MovementDirection direction = MovementDirection.Right;
  final ValueChanged<MovementDirection> onDirectionChange;
  int directionChanges = 0;
  
  final ScoringCubit scoringCubit; // Add this

  BouncingBehaviour({required this.onDirectionChange, required this.scoringCubit});

  @override
  void onLoad() {
    super.onMount();
    startMoving();
  }

  void onResize() {
    super.onMount();
    startMoving();
  }

  void speedUp() {
    if (timeToBounce > 800) {
      timeToBounce -= 200;
    }
  }

  void slowDown() {
    timeToBounce += 200;
  }

  void startMoving() {
    if (parent is! PositionComponent) {
      throw Exception(
          'BouncingBehaviour can only be added to PositionComponent');
    }

    PositionComponent parentComponent = parent as PositionComponent;
    double distance;
    timeToBounce = gameRef.ballSpeed * 130;

    // Reverse direction when a collision is detected
    if (direction == MovementDirection.Right) {
      distance = gameRef.size.x - parentComponent.position.x;
    } else {
      distance = -parentComponent.position.x;
    }

    onDirectionChange(direction);


    // Play the sound based on the direction
    if (direction == MovementDirection.Right) {
      FlameAudio.play('blip_left.mp3');
    } else {
      FlameAudio.play('blip_right.mp3');
    }

    controller =
        EffectController(duration: timeToBounce / 1000.0, curve: Curves.easeOutQuad);
    parentComponent.add(
      MoveEffect.by(
        Vector2(distance, 0),
        controller,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (controller.completed) {
      // Reverse direction when a collision is detected
      direction = direction == MovementDirection.Right
          ? MovementDirection.Left
          : MovementDirection.Right;
      startMoving();
    }
  }
}

