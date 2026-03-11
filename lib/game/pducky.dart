import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:pducky/game/game.dart';
import 'package:pducky/l10n/l10n.dart';
import 'package:pducky/game/cubit/gameplay/session_speaking.dart';
import 'timed_form.dart';

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

  /// Whether to show keyboard hint labels under the on-screen buttons.
  ///
  /// On web we default to showing them. On mobile, we can switch this on after
  /// the first detected key event.
  bool showKeyHints = kIsWeb;

  void enableKeyHints() {
    showKeyHints = true;
  }

  final AppLocalizations l10n;

  final AudioPlayer effectPlayer;

  final TextStyle textStyle;
  final FocusNode focusNode = FocusNode();

  late final DateTime startTime;
  late Ball puppyDuck;
  late GameplayButtons gameplayButtons;
  late final ScoringCubit scoringCubit;
  late final SessionCubit sessionCubit;
  late final SessionSpeaking sessionSpeaking;

  void startRoundWithThought(String thought, {bool skipIntro = false}) {
    sessionCubit.resetTime();
    sessionCubit.updateThought(thought);

    // Guided round normally begins at 60s (after intro). If skipping intro, the
    // guided round begins immediately at t=0.
    sessionCubit.setRoundStartSeconds(skipIntro ? 0 : 60);

    sessionSpeaking.loadSpeechComponents(
      sessionCubit,
      this,
      skipIntro: skipIntro,
    );
  }

  void showPauseMenu() {
    overlays.add('PauseMenu');
  }

  void hidePauseMenu() {
    overlays.remove('PauseMenu');
  }

  void showDistressForm() {
    overlays.add('DistressForm');
  }

  int counter = 0;

  @override
  Color backgroundColor() => Color.fromARGB(255, 51, 64, 129);

  @override
  Future<void> onLoad() async {
    // Add the overlay here

    final gameSize = size;
    scoringCubit = ScoringCubit();
    sessionCubit = SessionCubit(this);
    sessionSpeaking = SessionSpeaking();

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
    // Speech / round script is loaded after the user sets their thought.

    camera = CameraComponent(world: world);
    await addAll([world, camera]);

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
