import 'package:flame/collisions.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Walls {
  final Wall leftWall;
  final Wall rightWall;

  Walls({required Vector2 gameSize})
      : leftWall = Wall.left(gameSize: gameSize),
        rightWall = Wall.right(gameSize: gameSize);
}


class Wall extends PositionedEntity  {
  static final Vector2 _wallSize = Vector2(3, double.infinity);

  Wall._({
    required Vector2 center,
  }) : super(
          position: center,
          size: _wallSize,
          anchor: Anchor.center,
          children: [
            RectangleComponent.relative(
              Vector2.all(1),
              parentSize: _wallSize,
              paint: Paint()..color = Colors.yellow,
            ),
            RectangleHitbox(),
          ],
        );

Wall.left({
  required Vector2 gameSize,
}) : this._(
    center: Vector2(3 / 2 + 5, gameSize.y / 2), // Add 5 pixels to the x-coordinate
);

Wall.right({
  required Vector2 gameSize,
}) : this._(
    center: Vector2(gameSize.x - 3 / 2 - 5, gameSize.y / 2), // Subtract 5 pixels from the x-coordinate
);



         @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    if (position.x == 0) { // left wall
      position.y = gameSize.y / 2;
    } else { // right wall
      position.setValues(gameSize.x, gameSize.y / 2);
    }
  }
}