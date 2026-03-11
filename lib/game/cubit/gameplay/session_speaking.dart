import 'package:pducky/game/components/components.dart';
import 'package:pducky/game/cubit/cubit.dart';
import 'package:pducky/game/pducky.dart';
import 'package:pducky/game/entities/entities.dart';
import 'package:pducky/game/cubit/gameplay/round10_schedule.dart';

abstract class Startable {
  void start();
}

class TimedSpeechComponent {
  final SpeechComponent speechComponent;
  final int startTime;

  TimedSpeechComponent({
    required this.speechComponent,
    required this.startTime,
  });
}

class TimedCueComponent {
  final CueComponent cueComponent;
  final int startTime;

  TimedCueComponent({
    required this.cueComponent,
    required this.startTime,
  });
}


class SessionSpeaking {
  void loadSpeechComponents(
    SessionCubit sessionCubit,
    Pducky game, {
    bool skipIntro = false,
  }) {
    sessionCubit.timedSpeechComponents = [
      if (!skipIntro)

      TimedSpeechComponent(
        speechComponent: SpeechComponent(
          ball: game.puppyDuck,
          sessionCubit: sessionCubit,
          filename: 'hi,_and_welcome_to_puppyduck',
        ),
        startTime: 3,
      ),
      TimedSpeechComponent(
        speechComponent: SpeechComponent(
          ball: game.puppyDuck,
          sessionCubit: sessionCubit,
          filename:
              'today,_we_are_going_to_be_working_on_that_negative_thought_you_just_can\'t_seem_to_shake',
        ),
        startTime: 7,
      ),
      TimedSpeechComponent(
        speechComponent: SpeechComponent(
          ball: game.puppyDuck,
          sessionCubit: sessionCubit,
          filename:
              'psychologists_call_this_rumination,_and_it_has_been_linked_to_negative_mental_health_outcomes',
        ),
        startTime: 15,
      ),
      TimedSpeechComponent(
        speechComponent: SpeechComponent(
          ball: game.puppyDuck,
          sessionCubit: sessionCubit,
          filename:
              'I_want_you_to_focus_on_the_ball_going_side_to_side._When_its_in_the_scoring_zone,_tap_the_matching_puppy...or_duck..._to_score',
        ),
        startTime: 22,
      ),
      TimedSpeechComponent(
        speechComponent: SpeechComponent(
          ball: game.puppyDuck,
          sessionCubit: sessionCubit,
          filename:
              'don\'t_worry_too_much_about_the_score_though,_this_is_really_about_engaging_bilateral_stimulation',
        ),
        startTime: 35,
      ),
      TimedSpeechComponent(
        speechComponent: SpeechComponent(
          ball: game.puppyDuck,
          sessionCubit: sessionCubit,
          filename:
              'for_best_results,_pop_on_some_headphones._Studies_have_shown_bilateral_stimulation_can_be_more_effective_if_visual,_tactile_and_auditory_stimulation_is_combined',
        ),
        startTime: 45,
      ),
    ];

    // 10-minute guided script (generic audio assets; user's thought is shown
    // separately on-screen as `Thought: ...`).
    sessionCubit.timedSpeechComponents.addAll(
      round10Lines
          .map(
            (line) => TimedSpeechComponent(
              speechComponent: SpeechComponent(
                ball: game.puppyDuck,
                sessionCubit: sessionCubit,
                filename: line.filename,
              ),
              startTime: line.startTimeSeconds,
            ),
          )
          .toList(),
    );

    sessionCubit.timedCueComponents = [];

    // Add the SpeechComponent instances to the game
    for (final timedSpeechComponent in sessionCubit.timedSpeechComponents) {
      sessionCubit.gameRef.add(timedSpeechComponent.speechComponent);
    }

    // Add cue components to the game
    for (final timedCueComponent in sessionCubit.timedCueComponents) {
      sessionCubit.gameRef.add(timedCueComponent.cueComponent);
    }
  }
}
