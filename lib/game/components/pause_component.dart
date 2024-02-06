import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:pducky/game/components/button_component.dart';
import 'package:pducky/game/cubit/gameplay/scoring_cubit.dart';
import 'package:flutter/foundation.dart';

class PauseButton extends GameButton {
  bool isPaused = false;

  PauseButton({
    required Vector2 position,
    required ButtonSide side,
    required ButtonImage image,
    required ScoringCubit scoringCubit,
  }) : super(
          position: position,
          side: side,
          image: image,
          onTap: () {},
          scoringCubit: scoringCubit,
        );

  @override
  void handleButtonPress() {
    if (isPaused) {
      gameRef.resumeEngine();
      isPaused = false;
    } else {
      gameRef.pauseEngine();
      isPaused = true;
    }
  }

  @override
  bool onTapDown(TapDownEvent event) {
    handleButtonPress();
    return false;
  }
}