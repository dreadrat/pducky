import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/painting.dart';
import 'package:pducky/game/components/pause_component.dart';
import 'package:pducky/game/game.dart';
import 'package:pducky/game/entities/ball/behaviors/behaviors.dart';
import 'package:pducky/l10n/l10n.dart';

import 'entities/entities.dart';

class Pducky extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  Pducky(
      {required this.l10n,
      required this.effectPlayer,
      required this.textStyle}) {
    images.prefix = '';
    debugMode = true;
  }

  final AppLocalizations l10n;

  final AudioPlayer effectPlayer;

  final TextStyle textStyle;

  late final DateTime startTime;
  late final Ball puppyDuck;
  late GameplayButtons gameplayButtons;

  int counter = 0;

  @override
  Color backgroundColor() => const Color(0xFF2A48DF);

  @override
  Future<void> onLoad() async {
    Vector2 gameSize = size;
    ScoringCubit scoringCubit = ScoringCubit();

    final world = World(
      children: [
        puppyDuck = Ball(position: size / 2, scoringCubit: scoringCubit),
        ScoringZone(
          gameSize: size,
          side: 'left',
          scoringCubit: scoringCubit,
        ),
        // Add the right scoring zone
        ScoringZone(
          gameSize: size,
          side: 'right',
          scoringCubit: scoringCubit,
        ),
        puppyDuck,
        StopwatchComponent(),
        GameplayButtons(scoringCubit: scoringCubit),
        ScoreBoardComponent(scoringCubit),

        // Add the left scoring zone
      ],
    );
    startTime = DateTime.now();

    final camera = CameraComponent(world: world);
    await addAll([world, camera]);

    camera.viewfinder.position = size / 2;
    camera.viewfinder.zoom = 1;
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    resetGame();
  }

  void resetGame() {}
}
