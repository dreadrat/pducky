import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pducky/game/cubit/cubit.dart';

enum ButtonSide { Left, Right, Center }

enum ButtonImage { Puppy, Duck, Minus, Plus, Pause, Play }

class GameButton extends PositionedEntity
    with HasGameRef, TapCallbacks, KeyboardHandler {
  final ButtonSide side;
  ButtonImage image;
  final VoidCallback onTap;
  final ScoringCubit scoringCubit;
  final positionType = PositionType.game;

  late SpriteComponent _spriteComponent;
  SpriteComponent get spriteComponent =>
      _spriteComponent; // Provide a getter for _spriteComponent

  GameButton(
      {required super.position,
      required this.side,
      required this.image,
      required this.onTap,
      required this.scoringCubit,
      positionType = PositionType.viewport})
      : super(
          anchor: Anchor.center,
          size: Vector2.all(0),
          behaviors: [],
        );

  @override
  Future<void> onLoad() async {
    buttonLayouts();
    await addButtonImage();
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size.setValues(gameRef.size.y * 0.1, gameRef.size.y * 0.1);
    buttonLayouts();
  }

  Future<void> addButtonImage() async {
    final sprite = await gameRef.loadSprite(
      'assets/images/' +
          {
            ButtonImage.Puppy: 'puppy.png',
            ButtonImage.Duck: 'duck.png',
            ButtonImage.Minus: 'minus.png',
            ButtonImage.Plus: 'plus.png',
            ButtonImage.Pause: 'pause.png',
            ButtonImage.Play: 'play.png',
          }[image]!,
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
          : side == ButtonSide.Center
              ? gameRef.size.x * 0.5
              : (image == ButtonImage.Puppy
                  ? gameRef.size.x * 0.9
                  : gameRef.size.x * 0.8),
      side == ButtonSide.Center
          ? gameRef.size.y * 0.9
          : image == ButtonImage.Puppy
              ? gameRef.size.y * 0.9
              : gameRef.size.y * 0.75,
    );
  }

  void handleButtonPress() {
    onTap();
    BallImage ballImage =
        image == ButtonImage.Puppy ? BallImage.Puppy : BallImage.Duck;
    scoringCubit.checkForScore(ballImage);

    print('Button image: $image');
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
  void onTapDown(TapDownEvent event) {
    handleButtonPress();
  }

  @override
  bool onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isKeyDown = event is RawKeyDownEvent;

    final isAKey = keysPressed.contains(LogicalKeyboardKey.keyA);
    final isZKey = keysPressed.contains(LogicalKeyboardKey.keyZ);
    final isMKey = keysPressed.contains(LogicalKeyboardKey.keyM);
    final isKKey = keysPressed.contains(LogicalKeyboardKey.keyK);

    if (isKeyDown) {
      if (isZKey && side == ButtonSide.Left && image == ButtonImage.Puppy) {
        handleButtonPress();
        return false;
      } else if (isAKey &&
          side == ButtonSide.Left &&
          image != ButtonImage.Puppy) {
        handleButtonPress();
        return false;
      } else if (isMKey &&
          side == ButtonSide.Right &&
          image == ButtonImage.Puppy) {
        handleButtonPress();
        return false;
      } else if (isKKey &&
          side == ButtonSide.Right &&
          image != ButtonImage.Puppy) {
        handleButtonPress();
        return false;
      }
    }

    return true;
  }

  void changeButtonImage(ButtonImage newImage) async {
    final newSprite = await gameRef.loadSprite(
      'assets/images/' +
          {
            ButtonImage.Puppy: 'puppy.png',
            ButtonImage.Duck: 'duck.png',
            ButtonImage.Minus: 'minus.png',
            ButtonImage.Plus: 'plus.png',
            ButtonImage.Pause: 'pause.png',
            ButtonImage.Play: 'play.png',
          }[newImage]!,
    );

    // Remove the old sprite component from the game
    remove(_spriteComponent);

    // Create a new sprite component with the updated sprite
    _spriteComponent = SpriteComponent(
      sprite: newSprite,
      size: size,
    );

    // Add the new sprite component to the game
    add(_spriteComponent);
  }
}
