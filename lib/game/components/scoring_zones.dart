import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';
import 'package:pducky/game/game.dart';

class ScoringZone extends PositionedEntity
    with HasGameRef<Pducky>, CollisionCallbacks {

  // Add a new field for the ScoringCubit

  ScoringZone({
    required this.gameSize,
    required this.side,
    required this.scoringCubit,
  }) : super(
          position: Vector2.zero(),
          size: Vector2.zero(),
          anchor: Anchor.topLeft,
        );
  final ScoringCubit scoringCubit;

  final Vector2 gameSize;
  final String side;
  @override
  bool isColliding =
      false; // Add a new property to track whether the ScoringZone is colliding

  @override
  Future<void> onLoad() async {
    // Set the size of the ScoringZone
    size.setValues(gameSize.y * .05, gameSize.y * 0.5);

    // Set the position of the ScoringZone based on the side
    if (side == 'left') {
      position.setFrom(Vector2.zero()); // The top left corner of the game
    } else if (side == 'right') {
      position.setFrom(
          Vector2(gameSize.x - size.x, 0),); // The top right corner of the game
    }

    // Wait for the ScoringZone to be fully loaded before adding it to the game
    await super.onLoad();

    // Add the ScoringZone to the game's collision detection system
    gameRef.add(this);

    final hitbox = RectangleHitbox(size: size);
    add(hitbox);
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
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
      ..color = scoringCubit.scoringZoneColorNotifier.value == Colors.green
          ? Colors.green.withOpacity(
              0.5,) // Change the color to green when the user scores
          : isColliding
              ? const Color.fromARGB(255, 167, 187, 204).withOpacity(0.1)
              : const Color.fromARGB(255, 69, 81, 146).withOpacity(1);

    // Draw a rounded rectangle with the size and position of the ScoringZone
    const radius = Radius.circular(
        20,); // Adjust this value to change the roundness of the corners
    final rrect = RRect.fromRectAndRadius(size.toRect(), radius);
    canvas.drawRRect(rrect, paint);
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);

    // Set the size of the ScoringZone
    size.setValues(gameSize.y * .05, gameSize.y * 0.5);

    // Set the position of the ScoringZone based on the side
    if (side == 'left') {
      position.setFrom(Vector2.zero()); // The top left corner of the game
    } else if (side == 'right') {
      position.setFrom(
          Vector2(gameSize.x - size.x, 0),); // The top right corner of the game
    }
  }
}
