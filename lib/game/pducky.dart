import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/painting.dart';
import 'package:pducky/game/game.dart';
import 'package:pducky/l10n/l10n.dart';
import 'package:pducky/game/cubit/gameplay/session_speaking.dart';

class Pducky extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  Pducky({
    required this.l10n,
    required this.effectPlayer,
    required this.textStyle,
  }) {
    images.prefix = '';
    debugMode = false;
  }

  final AppLocalizations l10n;

  final AudioPlayer effectPlayer;

  final TextStyle textStyle;

  late final DateTime startTime;
  late Ball puppyDuck;
  late GameplayButtons gameplayButtons;

  int counter = 0;

  final List<SpeechComponent> speechComponents = [];
  final List<double> triggerTimes = [];

  @override
  Color backgroundColor() => const Color(0xFF2A48DF);

  @override
  Future<void> onLoad() async {
    final gameSize = size;
    final scoringCubit = ScoringCubit();
    final sessionCubit = SessionCubit();
    final sessionSpeaking = SessionSpeaking();

    final world = World(
      children: [
        puppyDuck = Ball(
          position: Vector2(0, gameSize.y / 3),
          scoringCubit: scoringCubit,
          sessionCubit: sessionCubit,
        ),
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
        StopwatchComponent(sessionCubit),
        GameplayButtons(scoringCubit: scoringCubit),
        ScoreBoardComponent(scoringCubit),

        // Add the left scoring zone
      ],
    );
    startTime = DateTime.now();

    camera = CameraComponent(world: world);
    await addAll([world, camera]);
    sessionSpeaking.loadSpeechComponents(sessionCubit);

    camera.viewfinder.position = size / 2;
    camera.viewfinder.zoom = 1;
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    camera.viewfinder.position = size / 2;
    camera.viewfinder.zoom = 1;
  }
}
