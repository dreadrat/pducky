import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:pducky/game/entities/ball/behaviors/collision_behaviour.dart';
import 'package:pducky/game/game.dart';
import 'package:pducky/game/pducky.dart';
import 'package:pducky/game/cubit/cubit.dart';

class ScoringZone extends PositionedEntity
    with HasGameRef<Pducky>, CollisionCallbacks {
        final ScoringCubit scoringCubit;
         // Add a new field for the ScoringCubit

  ScoringZone({
    required this.puppyDuckSize,
    required this.gameSize,
    required this.side,
    required this.scoringCubit,
  }) : super(
          position: Vector2.zero(),
          size: Vector2.zero(),
          anchor: Anchor.topLeft,
          behaviors: [
            CollidableBehavior(),
          ],
        );

  final Vector2 puppyDuckSize;
  final Vector2 gameSize;
  final String side;
  bool isColliding =
      false; // Add a new property to track whether the ScoringZone is colliding

  @override
  Future<void> onLoad() async {
    // Set the size of the ScoringZone
    size.setValues(puppyDuckSize.y / 2, gameSize.y * 2 / 3);

    // Set the position of the ScoringZone based on the side
    if (side == 'left') {
      position.setFrom(Vector2.zero()); // The top left corner of the game
    } else if (side == 'right') {
      position.setFrom(
          Vector2(gameSize.x - size.x, 0)); // The top right corner of the game
    }

    // Wait for the ScoringZone to be fully loaded before adding it to the game
    await super.onLoad();

    // Add the ScoringZone to the game's collision detection system
    gameRef.add(this);

    final hitbox = RectangleHitbox(size: size);
    add(hitbox);
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    super.onCollision(points, other);
    if (other is Ball) {
      isColliding = true;
      scoringCubit.updateBallInScoringZone(true);
      // Additional logic if needed
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is Ball) {
      isColliding = false;
      scoringCubit.updateBallInScoringZone(false);
      // Additional logic if needed
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Create a paint with the desired color and opacity
    final paint = BasicPalette.blue.paint()
      ..color = isColliding
          ? Colors.blue.withOpacity(0.1)
          : Color.fromARGB(255, 229, 229, 229).withOpacity(0.0);

    // Draw a rectangle with the size and position of the ScoringZone
    canvas.drawRect(size.toRect(), paint);
  }

  @override
void onGameResize(Vector2 gameSize) {
  super.onGameResize(gameSize);

  // Set the size of the ScoringZone
  size.setValues(puppyDuckSize.y / 2, gameSize.y * 2 / 3);

  // Set the position of the ScoringZone based on the side
  if (side == 'left') {
    position.setFrom(Vector2.zero()); // The top left corner of the game
  } else if (side == 'right') {
    position.setFrom(Vector2(gameSize.x - size.x, 0)); // The top right corner of the game
  }
}

}
