import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';

enum MovementDirection { Left, Right }

class BouncingBehaviour extends Behavior with HasGameRef {
  int timeToBounce = 2000;
  late EffectController controller;
  MovementDirection direction = MovementDirection.Right;
  final ValueChanged<MovementDirection> onDirectionChange; // Modify this line

  BouncingBehaviour({required this.onDirectionChange}); // No change here

  @override
  void onMount() {
    super.onMount();
    startMoving();
  }

  void startMoving() {
    if (parent is! PositionComponent) {
      throw Exception(
          'BouncingBehaviour can only be added to PositionComponent');
    }

    PositionComponent parentComponent = parent as PositionComponent;
    double distance;

    // If the object is on the left half of the screen, move it to the right edge
    if (parentComponent.position.x <= gameRef.size.x / 2) {
      parentComponent.position.x = 0; // Start at the left edge of the screen
      distance = gameRef.size.x; // Move to the right edge of the screen
      direction = MovementDirection.Right; // Set the direction of movement
    }
    // If the object is on the right half of the screen, move it to the left edge
    else {
      parentComponent.position.x =
          gameRef.size.x; // Start at the right edge of the screen
      distance = -gameRef.size.x; // Move to the left edge of the screen
      direction = MovementDirection.Left; // Set the direction of movement
    }

    onDirectionChange(direction); // Modify this line

    controller =
        EffectController(duration: timeToBounce / 1000.0, curve: Curves.linear);
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
      startMoving();
    }
  }
}
