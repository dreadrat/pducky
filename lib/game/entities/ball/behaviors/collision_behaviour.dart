import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame/collisions.dart';
import 'package:pducky/game/pducky.dart';
import 'package:flame/geometry.dart'; // Import geometry for Collidable

class CollidableBehavior extends Behavior
    with HasGameRef<Pducky>, CollisionCallbacks {
  double opacity = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    super.onCollision(points, other); // Call the super implementation
    // Check for collision with the PuppyDuck
    print('in THE ZOOOONE!!!!!!!');
    if (other == gameRef.puppyDuck) {
      // If a collision is detected, set the opacity to 0.5
      opacity = 0.0;
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    // Check if the collision with PuppyDuck has ended
    if (other == gameRef.puppyDuck) {
      // Reset the opacity
      opacity = 0.5;
    }
  }
}
