import 'package:pducky/game/components/components.dart';
import 'package:pducky/game/cubit/cubit.dart';

class TimedSpeechComponent {
  final SpeechComponent speechComponent;
  final int startTime;

  TimedSpeechComponent({
    required this.speechComponent,
    required this.startTime,
  });
}

class SessionSpeaking {
  void loadSpeechComponents(SessionCubit sessionCubit) {
    sessionCubit.timedSpeechComponents = [
      TimedSpeechComponent(
        speechComponent: SpeechComponent(
          sessionCubit: sessionCubit,
          filename: 'hi,_and_welcome_to_puppyduck',
        ),
        startTime: 2, // Start time in seconds
      ),
      TimedSpeechComponent(
        speechComponent: SpeechComponent(
          sessionCubit: sessionCubit,
          filename:
              'today,_we_are_going_to_be_working_on_that_negative_thought_you_just_can\'t_seem_to_shake',
        ),
        startTime: 10, // Start time in seconds
      ),
      TimedSpeechComponent(
        speechComponent: SpeechComponent(
          sessionCubit: sessionCubit,
          filename:
              'focus_on_the_ball_going_side_to_side_and_tap_either_puppy_or_duck_when_the_ball_is_in_the_scoring_zone_to_score._',
        ),
        startTime: 16, // Start time in seconds
      ),
      TimedSpeechComponent(
        speechComponent: SpeechComponent(
          sessionCubit: sessionCubit,
          filename:
              'don\'t_worry_too_much_about_your_score_though,_this_is_about_engaging_bilateral_stimulation_',
        ),
        startTime: 22, // Start time in seconds
      ),
      TimedSpeechComponent(
        speechComponent: SpeechComponent(
          sessionCubit: sessionCubit,
          filename:
              'for_best_results,_make_sure_you_pop_your_headphones_on,_as_studies_have_shown_that_bilateral_stimulation_can_be_more_effective_if_the_visual,_tactile_and_auditory_stimulation_is_combined',
        ),
        startTime: 28, // Start time in seconds
      ),

      TimedSpeechComponent(
        speechComponent: SpeechComponent(
          sessionCubit: sessionCubit,
          filename:
              'But_first_lets_stop_and_get_a_little_bit_of_information_about_the_negative_thought_you_want_to_deal_with_today._',
        ),
        startTime: 35, // Start time in seconds
      ),

      // Add more TimedSpeechComponents as needed
    ];
  }
}
