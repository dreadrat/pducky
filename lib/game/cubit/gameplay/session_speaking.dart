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

    // 10-minute guided script (generic audio assets; user's thought is shown
    // separately on-screen as `Thought: ...`).
    sessionCubit.timedSpeechComponents.addAll([
      TimedSpeechComponent(
        speechComponent: SpeechComponent(
          ball: game.puppyDuck,
          sessionCubit: sessionCubit,
          filename:
              'Welcome._You’ve_already_named_the_thought_and_rated_how_strong_it_feels._Nice_work.',
        ),
        startTime: 60,
      ),
      TimedSpeechComponent(
        speechComponent: SpeechComponent(
          ball: game.puppyDuck,
          sessionCubit: sessionCubit,
          filename:
              'For_this_round,_we’re_not_trying_to_argue_with_the_thought_or_push_it_away._We’re_practising_noticing_it.',
        ),
        startTime: 105,
      ),
      TimedSpeechComponent(
        speechComponent: SpeechComponent(
          ball: game.puppyDuck,
          sessionCubit: sessionCubit,
          filename:
              'As_you_play,_let_the_thought_sit_quietly_in_the_background._If_it_feels_loud,_that’s_okay.',
        ),
        startTime: 150,
      ),
      TimedSpeechComponent(
        speechComponent: SpeechComponent(
          ball: game.puppyDuck,
          sessionCubit: sessionCubit,
          filename:
              'Do_a_gentle_body_check._Where_do_you_feel_it__Chest,_throat,_stomach,_jaw,_shoulders.',
        ),
        startTime: 210,
      ),
      TimedSpeechComponent(
        speechComponent: SpeechComponent(
          ball: game.puppyDuck,
          sessionCubit: sessionCubit,
          filename:
              'If_you_can,_name_the_feeling_that_comes_with_it._Just_one_word_is_enough.',
        ),
        startTime: 270,
      ),
      TimedSpeechComponent(
        speechComponent: SpeechComponent(
          ball: game.puppyDuck,
          sessionCubit: sessionCubit,
          filename:
              'Try_adding_a_little_space__I’m_having_the_thought_that…_and_then_add_your_thought_on_the_end.',
        ),
        startTime: 330,
      ),
      TimedSpeechComponent(
        speechComponent: SpeechComponent(
          ball: game.puppyDuck,
          sessionCubit: sessionCubit,
          filename:
              'Now_let_it_be_there,_and_bring_your_attention_back_to_the_ball._Thought,_body,_ball.',
        ),
        startTime: 390,
      ),
      TimedSpeechComponent(
        speechComponent: SpeechComponent(
          ball: game.puppyDuck,
          sessionCubit: sessionCubit,
          filename:
              'Imagine_a_friend_had_this_exact_thought._What_would_you_say_to_them__Keep_it_simple_and_kind.',
        ),
        startTime: 480,
      ),
      TimedSpeechComponent(
        speechComponent: SpeechComponent(
          ball: game.puppyDuck,
          sessionCubit: sessionCubit,
          filename:
              'Zoom_out_slightly._Is_the_thought_pulling_you_to_the_past,_the_present,_or_the_future_',
        ),
        startTime: 555,
      ),
      TimedSpeechComponent(
        speechComponent: SpeechComponent(
          ball: game.puppyDuck,
          sessionCubit: sessionCubit,
          filename:
              'If_you_want,_hold_one_small_balanced_sentence_alongside_it._Like__This_is_a_thought,_not_a_fact.',
        ),
        startTime: 630,
      ),
      TimedSpeechComponent(
        speechComponent: SpeechComponent(
          ball: game.puppyDuck,
          sessionCubit: sessionCubit,
          filename:
              'Last_check-in._Notice_what’s_changed,_even_a_little._Take_a_slow_breath.',
        ),
        startTime: 720,
      ),
    ]);

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
