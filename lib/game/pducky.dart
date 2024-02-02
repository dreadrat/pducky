import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/painting.dart';
import 'package:pducky/game/game.dart';
import 'package:pducky/game/entities/ball/behaviors/behaviors.dart';
import 'package:pducky/l10n/l10n.dart';

import 'entities/entities.dart';


class Pducky extends FlameGame with HasCollisionDetection, HasKeyboardHandlerComponents {
  

  Pducky({
    required this.l10n,
    required this.effectPlayer,
    required this.textStyle
  }) {
    images.prefix = '';
     //debugMode = true;
  }

  final AppLocalizations l10n;

  final AudioPlayer effectPlayer;

  final TextStyle textStyle;

  late final DateTime startTime;
  late final Ball puppyDuck;
  


  int ballSpeed = 50;
  double accelleration = 5.0;

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
          puppyDuckSize: Vector2(size.x * 0.2,
              size.y * 0.2), // Replace with the actual size of the PuppyDuck
          gameSize: size,
          side: 'left',
          scoringCubit: scoringCubit,
          
        ),
        // Add the right scoring zone
        ScoringZone(
          puppyDuckSize: Vector2(size.x * 0.2,
              size.y * 0.2), // Replace with the actual size of the PuppyDuck
          gameSize: size,
          side: 'right',
          scoringCubit: scoringCubit,
        ),
        puppyDuck,
        StopwatchComponent(
          position: (size / 2)
            ..sub(
              Vector2(0, 116),
            ),
        ),
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




}
