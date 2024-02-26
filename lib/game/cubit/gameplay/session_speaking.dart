import 'package:pducky/game/components/components.dart';
import 'package:pducky/game/cubit/cubit.dart';
import 'package:pducky/game/pducky.dart';

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
          sessionCubit: sessionCubit,
          filename: 'hi,_and_welcome_to_puppyduck',
        ),
        startTime: 3, // Start time in seconds
      ),
      TimedSpeechComponent(
        speechComponent: SpeechComponent(
          sessionCubit: sessionCubit,
          filename:
              'today,_we_are_going_to_be_working_on_that_negative_thought_you_just_can\'t_seem_to_shake',
        ),
        startTime: 10, // Start time in seconds
      ),
      // Add more TimedSpeechComponents as needed
    ];

    // Add the SpeechComponent instances to the game
    for (var timedSpeechComponent in sessionCubit.timedSpeechComponents) {
      sessionCubit.gameRef.add(timedSpeechComponent.speechComponent);
    }
  }
}
