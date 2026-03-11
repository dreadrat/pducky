import 'package:pducky/game/components/components.dart';
import 'package:pducky/game/cubit/cubit.dart';
import 'package:pducky/game/pducky.dart';
import 'package:pducky/game/entities/entities.dart';

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
  void loadSpeechComponents(SessionCubit sessionCubit, Pducky game) {
    sessionCubit.timedSpeechComponents = [
      TimedSpeechComponent(
        speechComponent: SpeechComponent(
          ball: game.puppyDuck,
          sessionCubit: sessionCubit,
          filename: 'hi,_and_welcome_to_puppyduck',
        ),
        startTime: 3, // Start time in seconds
      ),
      TimedSpeechComponent(
        speechComponent: SpeechComponent(
          ball: game.puppyDuck,
          sessionCubit: sessionCubit,
          filename:
              'today,_we_are_going_to_be_working_on_that_negative_thought_you_just_can\'t_seem_to_shake',
        ),
        startTime: 7, // Start time in seconds
      ),
      TimedSpeechComponent(
        speechComponent: SpeechComponent(
          ball: game.puppyDuck,
          sessionCubit: sessionCubit,
          filename:
              'psychologists_call_this_rumination,_and_it_has_been_linked_to_negative_mental_health_outcomes',
        ),
        startTime: 15, // Start time in seconds
      ),
      TimedSpeechComponent(
        speechComponent: SpeechComponent(
          ball: game.puppyDuck,
          sessionCubit: sessionCubit,
          filename:
              'I_want_you_to_focus_on_the_ball_going_side_to_side._When_its_in_the_scoring_zone,_tap_the_matching_puppy...or_duck..._to_score',
        ),
        startTime: 22, // Start time in seconds
      ),
      TimedSpeechComponent(
        speechComponent: SpeechComponent(
          ball: game.puppyDuck,
          sessionCubit: sessionCubit,
          filename:
              'don\'t_worry_too_much_about_the_score_though,_this_is_really_about_engaging_bilateral_stimulation',
        ),
        startTime: 35, // Start time in seconds
      ),
      TimedSpeechComponent(
        speechComponent: SpeechComponent(
          ball: game.puppyDuck,
          sessionCubit: sessionCubit,
          filename:
              'for_best_results,_pop_on_some_headphones._Studies_have_shown_bilateral_stimulation_can_be_more_effective_if_visual,_tactile_and_auditory_stimulation_is_combined',
        ),
        startTime: 45, // Start time in seconds
      ),
      // Add more TimedSpeechComponents as needed
    ];
    // 10-minute round prototype (web-safe): text cues during play.
    //
    // Option A: audio lines are generic assets; the user's thought is displayed
    // separately on screen (see Ball thought label).
    sessionCubit.timedCueComponents = [
      TimedCueComponent(
        cueComponent: CueComponent(
          sessionCubit: sessionCubit,
          text: 'No judgement — just noticing.',
          displaySeconds: 2.5,
        ),
        startTime: 60,
      ),
      TimedCueComponent(
        cueComponent: CueComponent(
          sessionCubit: sessionCubit,
          text: 'Keep the thought lightly in mind.',
          displaySeconds: 2.5,
        ),
        startTime: 90,
      ),
      TimedCueComponent(
        cueComponent: CueComponent(
          sessionCubit: sessionCubit,
          text: 'Where do you feel it in your body?',
          displaySeconds: 2.5,
        ),
        startTime: 120,
      ),
      TimedCueComponent(
        cueComponent: CueComponent(
          sessionCubit: sessionCubit,
          text: 'Name the feeling (one word).',
          displaySeconds: 2.5,
        ),
        startTime: 150,
      ),
      TimedCueComponent(
        cueComponent: CueComponent(
          sessionCubit: sessionCubit,
          text: "Try: ‘I’m having the thought that…’",
          displaySeconds: 2.5,
        ),
        startTime: 180,
      ),
      TimedCueComponent(
        cueComponent: CueComponent(
          sessionCubit: sessionCubit,
          text: 'Thought… body… ball.',
          displaySeconds: 2.0,
        ),
        startTime: 240,
      ),
      TimedCueComponent(
        cueComponent: CueComponent(
          sessionCubit: sessionCubit,
          text: 'What would you tell a friend?',
          displaySeconds: 2.5,
        ),
        startTime: 330,
      ),
      TimedCueComponent(
        cueComponent: CueComponent(
          sessionCubit: sessionCubit,
          text: 'Notice what changed. Slow breath.',
          displaySeconds: 2.5,
        ),
        startTime: 560,
      ),
    ];

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
