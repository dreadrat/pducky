import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pducky/game/cubit/cubit.dart';
import 'package:pducky/game/pducky.dart';

enum ButtonSide { Left, Right, Center }

enum ButtonImage { Puppy, Duck, Minus, Plus, Pause, Play }

class GameButton extends PositionedEntity
    with HasGameRef, TapCallbacks, KeyboardHandler {
  GameButton({
    required super.position,
    required this.side,
    required this.image,
    required this.onTap,
    required this.scoringCubit,
    this.keyHint,
  }) : super(
          anchor: Anchor.center,
          size: Vector2.all(0),
          behaviors: [],
        );
  final ButtonSide side;
  ButtonImage image;
  final VoidCallback onTap;
  final ScoringCubit scoringCubit;
  final String? keyHint;

  late SpriteComponent _spriteComponent;
  SpriteComponent get spriteComponent => _spriteComponent;

  TextComponent? _keyHintComponent;
  bool _keyHintAdded = false;

  @override
  Future<void> onLoad() async {
    buttonLayouts();
    await addButtonImage();
    _createKeyHint();
  }

  void _createKeyHint() {
    if (keyHint == null) return;

    _keyHintComponent = TextComponent(
      text: keyHint,
      anchor: Anchor.topCenter,
    );

    _layoutKeyHint();
  }

  void _layoutKeyHint() {
    if (_keyHintComponent == null) return;

    // Position just under the button sprite.
    _keyHintComponent!
      ..position = Vector2(size.x / 2, size.y + (size.y * 0.05))
      ..textRenderer = TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      );
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size.setValues(gameRef.size.y * 0.1, gameRef.size.y * 0.1);
    buttonLayouts();
    _layoutKeyHint();
  }

  Future<void> addButtonImage() async {
    final sprite = await gameRef.loadSprite(
      'assets/images/${{
        ButtonImage.Puppy: 'puppy.png',
        ButtonImage.Duck: 'duck.png',
        ButtonImage.Minus: 'minus.png',
        ButtonImage.Plus: 'plus.png',
        ButtonImage.Pause: 'pause.png',
        ButtonImage.Play: 'play.png',
      }[image]!}',
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
    final ballImage =
        image == ButtonImage.Puppy ? BallImage.Puppy : BallImage.Duck;
    scoringCubit.checkForScore(ballImage);

    add(
      SequenceEffect([
        ScaleEffect.by(
          Vector2.all(1.5),
          EffectController(
            duration: 0.1,
            alternate: true,
          ),
        ),
      ]),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    handleButtonPress();
  }

  @override
  void update(double dt) {
    super.update(dt);

    final shouldShow = (gameRef is Pducky) && (gameRef as Pducky).showKeyHints;

    if (_keyHintComponent != null && shouldShow && !_keyHintAdded) {
      add(_keyHintComponent!);
      _keyHintAdded = true;
    } else if (_keyHintComponent != null && !shouldShow && _keyHintAdded) {
      remove(_keyHintComponent!);
      _keyHintAdded = false;
    }
  }

  @override
  bool onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isKeyDown = event is KeyDownEvent;

    // If we ever receive key events, a keyboard is available; show hints.
    if (gameRef is Pducky) {
      (gameRef as Pducky).enableKeyHints();
    }

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

  Future<void> changeButtonImage(ButtonImage newImage) async {
    final newSprite = await gameRef.loadSprite(
      'assets/images/${{
        ButtonImage.Puppy: 'puppy.png',
        ButtonImage.Duck: 'duck.png',
        ButtonImage.Minus: 'minus.png',
        ButtonImage.Plus: 'plus.png',
        ButtonImage.Pause: 'pause.png',
        ButtonImage.Play: 'play.png',
      }[newImage]!}',
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
