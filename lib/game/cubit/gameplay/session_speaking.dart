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

class TimedLocalSpeech {
  final LocalSpeechComponent component;
  final int startTime;

  TimedLocalSpeech({
    required this.component,
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
    // 10-minute round prototype: spoken prompts that explicitly reference the
    // user's thought. These are generated locally (TTS) and synced word-by-word.
    final t = sessionCubit.state.thought.trim();
    final thoughtLine = t.isEmpty ? 'your thought' : 'the thought: “$t”';

    sessionCubit.timedLocalSpeech = [
      TimedLocalSpeech(
        component: LocalSpeechComponent(
          sessionCubit: sessionCubit,
          text: "Alright. For the next few minutes, we’re not judging it. Just notice $thoughtLine.",
        ),
        startTime: 10,
      ),
      TimedLocalSpeech(
        component: LocalSpeechComponent(
          sessionCubit: sessionCubit,
          text: "As you play, keep $thoughtLine lightly in mind. You don’t have to fix it.",
        ),
        startTime: 35,
      ),
      TimedLocalSpeech(
        component: LocalSpeechComponent(
          sessionCubit: sessionCubit,
          text: "Quick check-in: where do you feel $thoughtLine in your body right now?",
        ),
        startTime: 90,
      ),
      TimedLocalSpeech(
        component: LocalSpeechComponent(
          sessionCubit: sessionCubit,
          text: "See if you can name the feeling that comes with it. Just one word is enough.",
        ),
        startTime: 135,
      ),
      TimedLocalSpeech(
        component: LocalSpeechComponent(
          sessionCubit: sessionCubit,
          text: "Try this: ‘I’m having the thought that…’ and then add it on the end.",
        ),
        startTime: 180,
      ),
      TimedLocalSpeech(
        component: LocalSpeechComponent(
          sessionCubit: sessionCubit,
          text: "Now let it be there, and bring your attention back to the ball. Thought… body… ball.",
        ),
        startTime: 240,
      ),
      TimedLocalSpeech(
        component: LocalSpeechComponent(
          sessionCubit: sessionCubit,
          text: "If a friend had $thoughtLine, what would you say to them? Keep it gentle.",
        ),
        startTime: 330,
      ),
      TimedLocalSpeech(
        component: LocalSpeechComponent(
          sessionCubit: sessionCubit,
          text: "One last check. Notice what’s changed, even a little. Then take a slow breath.",
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

    // Add local TTS speech components to the game
    for (final timed in sessionCubit.timedLocalSpeech) {
      sessionCubit.gameRef.add(timed.component);
    }
  }
}
