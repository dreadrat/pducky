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
    // 10-minute round prototype: text-only cues during play.
    // These are deliberately short so they fit under the ball.
    sessionCubit.timedCueComponents = [
      // Non-judgement + grounding
      TimedCueComponent(
        cueComponent: CueComponent(
          sessionCubit: sessionCubit,
          text: 'No judgment',
        ),
        startTime: 60,
      ),
      TimedCueComponent(
        cueComponent: CueComponent(
          sessionCubit: sessionCubit,
          text: 'Thought ≠ fact',
        ),
        startTime: 90,
      ),
      TimedCueComponent(
        cueComponent: CueComponent(
          sessionCubit: sessionCubit,
          text: 'Where in body?',
        ),
        startTime: 120,
      ),
      TimedCueComponent(
        cueComponent: CueComponent(
          sessionCubit: sessionCubit,
          text: 'Name the feeling',
        ),
        startTime: 150,
      ),
      TimedCueComponent(
        cueComponent: CueComponent(
          sessionCubit: sessionCubit,
          text: "I'm having the thought…",
          displaySeconds: 2.5,
        ),
        startTime: 180,
      ),
      TimedCueComponent(
        cueComponent: CueComponent(
          sessionCubit: sessionCubit,
          text: 'Let it be here',
        ),
        startTime: 210,
      ),
      // Mid-round perspective + compassion
      TimedCueComponent(
        cueComponent: CueComponent(
          sessionCubit: sessionCubit,
          text: 'What would you tell a friend?',
          displaySeconds: 3,
        ),
        startTime: 270,
      ),
      TimedCueComponent(
        cueComponent: CueComponent(
          sessionCubit: sessionCubit,
          text: 'Back to the ball',
        ),
        startTime: 300,
      ),
      TimedCueComponent(
        cueComponent: CueComponent(
          sessionCubit: sessionCubit,
          text: 'One small next step',
          displaySeconds: 2.5,
        ),
        startTime: 360,
      ),
      TimedCueComponent(
        cueComponent: CueComponent(
          sessionCubit: sessionCubit,
          text: 'Be kind to yourself',
        ),
        startTime: 420,
      ),
      // End-of-round wrap
      TimedCueComponent(
        cueComponent: CueComponent(
          sessionCubit: sessionCubit,
          text: 'Notice what changed',
          displaySeconds: 2.5,
        ),
        startTime: 540,
      ),
      TimedCueComponent(
        cueComponent: CueComponent(
          sessionCubit: sessionCubit,
          text: 'Take a breath',
        ),
        startTime: 585,
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
