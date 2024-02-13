import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/widgets.dart';
import 'package:pducky/game/game.dart';

enum MovementDirection { Left, Right }

class BouncingBehaviour extends Behavior with HasGameRef<Pducky> {
  BouncingBehaviour(
      {required this.onDirectionChange, required this.scoringCubit,});
  late EffectController controller;
  MovementDirection direction = MovementDirection.Right;
  final ValueChanged<MovementDirection> onDirectionChange;
  int directionChanges = 0;

  late ScoringCubit scoringCubit; // Add this
  double timeToBounce = 0;

  @override
  void onLoad() {
    super.onLoad();
    startMoving();
  }

  void onResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    startMoving();
  }

  void startMoving() {
    final parentComponent = parent as PositionComponent;
    double distance;
    timeToBounce = scoringCubit.state.speed;

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

    controller = EffectController(
        duration: timeToBounce / 1000.0, curve: Curves.easeOut,);

    parentComponent.add(
      MoveEffect.by(
        Vector2(distance, 0),
        controller,
      ),
    );

// Add a SequenceEffect to scale up the component and then scale it back down
    parentComponent.add(
      SequenceEffect([
        ScaleEffect.to(
          Vector2.all(1.8), // Replace 1.5 with the desired growth factor
          controller,
        ),
        ScaleEffect.to(
          Vector2.all(0.5), // Scale back down to the original size
          EffectController(duration: 0),
        ),
      ]),
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
