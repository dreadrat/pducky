import 'package:pducky/game/components/components.dart';
import 'package:pducky/game/cubit/cubit.dart';
import 'package:pducky/game/pducky.dart';
import 'package:pducky/game/entities/entities.dart';

class TimedSpeechComponent {
  final SpeechComponent speechComponent;
  final int startTime;

  TimedSpeechComponent({
    required this.speechComponent,
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
    // Add the SpeechComponent instances to the game
    for (var timedSpeechComponent in sessionCubit.timedSpeechComponents) {
      sessionCubit.gameRef.add(timedSpeechComponent.speechComponent);
    }
  }
}
