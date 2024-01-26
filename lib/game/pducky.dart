import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';
import 'package:pducky/game/game.dart';
import 'package:pducky/l10n/l10n.dart';
import 'package:pducky/game/components/components.dart';
import 'package:pducky/game/cubit/gameplay/scoring_cubit.dart';

class Pducky extends FlameGame with HasCollisionDetection {
  final ScoringCubit? scoringCubit;

  Pducky({
    required this.l10n,
    required this.effectPlayer,
    required this.textStyle,
    required this.scoringCubit,
  }) {
    images.prefix = '';
  }

  final AppLocalizations l10n;

  final AudioPlayer effectPlayer;

  final TextStyle textStyle;

  late final DateTime startTime;
  late final Ball puppyDuck;

  int ballSpeed = 10;
  double accelleration = 5.0;

  int counter = 0;

  @override
  Color backgroundColor() => const Color(0xFF2A48DF);

  @override
  Future<void> onLoad() async {
    final world = World(
      children: [
        puppyDuck = Ball(position: size / 2),
        ScoringZone(
          puppyDuckSize: Vector2(size.x * 0.2,
              size.y * 0.2), // Replace with the actual size of the PuppyDuck
          gameSize: size,
          side: 'left',
        ),
        // Add the right scoring zone
        ScoringZone(
          puppyDuckSize: Vector2(size.x * 0.2,
              size.y * 0.2), // Replace with the actual size of the PuppyDuck
          gameSize: size,
          side: 'right',
        ),
        puppyDuck,
        StopwatchComponent(
          position: (size / 2)
            ..sub(
              Vector2(0, 116),
            ),
        ),
        GameplayButtons(),

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
