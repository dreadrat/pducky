import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/foundation.dart';
import 'package:pducky/game/cubit/cubit.dart';
import 'package:pducky/game/entities/entities.dart';

enum ButtonSide { Left, Right }

enum ButtonImage { Puppy, Duck, Minus, Plus }

class GameButton extends PositionedEntity with HasGameRef, TapCallbacks {
  final ButtonSide side;
  final ButtonImage image;
  final VoidCallback onTap;
  final ScoringCubit scoringCubit;

  GameButton({
    required super.position,
    required this.side,
    required this.image,
    required this.onTap,
    required this.scoringCubit,
  }) : super(
          anchor: Anchor.center,
          size: Vector2.all(0),
          behaviors: [
                    ],
        );

  late SpriteComponent _spriteComponent;

 

  @override
  Future<void> onLoad() async {
    buttonLayouts();
    await addButtonImage();
  }

  
 

  Future<void> addButtonImage() async {
     final sprite = await gameRef.loadSprite(
      'assets/images/${image == ButtonImage.Puppy ? 'puppy.png' : image == ButtonImage.Duck ? 'duck.png' : image == ButtonImage.Minus ? 'minus.png' : 'plus.png'}',
    );
    
    // Initialize and add the sprite component
    _spriteComponent = SpriteComponent(
      sprite: sprite,
      size: size,
    );
    await add(_spriteComponent);
  }

  

  void buttonLayouts() {
    size.setValues(gameRef.size.y * 0.1, gameRef.size.y * 0.1);
    position = Vector2(
      side == ButtonSide.Left
          ? (image == ButtonImage.Puppy
              ? gameRef.size.x * 0.1
              : gameRef.size.x * 0.2)
          : (image == ButtonImage.Puppy
              ? gameRef.size.x * 0.9
              : gameRef.size.x * 0.8),
      image == ButtonImage.Puppy ? gameRef.size.y * 0.9 : gameRef.size.y * 0.75,
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap();
    BallImage ballImage = image == ButtonImage.Puppy ? BallImage.Puppy : BallImage.Duck;
    scoringCubit.checkForScore(ballImage);

   // Print the button image
  print('Button image: $image()');
  
  // Print the scoring cubit's current image
  print('Scoring cubit image: ${scoringCubit.state.ballImage}');

    add(SequenceEffect([
      ScaleEffect.by(
        Vector2.all(1.5),
        EffectController(
          duration: 0.1,
          alternate: true,
        ),
      ),
    ]));

  }

  @override
  void onTapUp(TapUpEvent event) {
    // No action needed on tap up
  }
}
