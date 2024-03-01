import 'package:bloc/bloc.dart';
import 'package:flame/game.dart';
import 'package:pducky/game/cubit/gameplay/session_speaking.dart';
import 'package:pducky/game/timed_form.dart';

class SessionState {
  SessionState(
      {required this.elapsedTime,
      this.currentWord = '',
      this.isPaused = false});

  final double elapsedTime;
  final String currentWord;
  final bool isPaused;

  SessionState copyWith({String? currentWord, bool? isPaused}) {
    return SessionState(
      elapsedTime: elapsedTime,
      currentWord: currentWord ?? this.currentWord,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}

class SessionCubit extends Cubit<SessionState> {
  final FlameGame gameRef;
  List<TimedFormComponent> timedFormComponents = [];
  bool shouldCheckInputComponents = true;

  SessionCubit(this.gameRef, {String currentWord = ''})
      : super(SessionState(elapsedTime: 0, currentWord: currentWord)) {
    // Initialize timedFormComponents here
    timedFormComponents = [
      TimedFormComponent(startTime: 10.0, cubit: this),
    ];
  }

  List<TimedSpeechComponent> timedSpeechComponents = [];

  void updateCurrentWord(String word) {
    emit(state.copyWith(currentWord: word));
  }

  void checkSpeechComponents() {
    var timedSpeechComponentsCopy =
        List<TimedSpeechComponent>.from(timedSpeechComponents);
    for (var timedSpeechComponent in timedSpeechComponentsCopy) {
      if (state.elapsedTime >= timedSpeechComponent.startTime) {
        timedSpeechComponent.speechComponent.start();
        timedSpeechComponents.remove(timedSpeechComponent);
      }
    }
  }

  void checkInputComponents() {
    if (!shouldCheckInputComponents) {
      return;
    }

    var timedFormComponentsCopy =
        List<TimedFormComponent>.from(timedFormComponents);
    for (var timedFormComponent in timedFormComponentsCopy) {
      if (!timedFormComponent.isAdded &&
          state.elapsedTime >= timedFormComponent.startTime &&
          state.elapsedTime < timedFormComponent.startTime + 1) {
        print('Matched input components');
        gameRef.add(timedFormComponent);
        timedFormComponent.isAdded = true;
        print('Added timedFormComponent to game');
        timedFormComponent.startDistressForm(this);
        print('Started distress form');
        shouldCheckInputComponents = false;
        print('shouldCheckInputComponents is now $shouldCheckInputComponents');
        return;
      } else {
        print('No match: elapsed time is ${state.elapsedTime}');
      }
    }
  }

  void incrementTime(double dt) {
    if (!state.isPaused) {
      final newTime = state.elapsedTime + dt;
      emit(SessionState(elapsedTime: newTime));
      checkSpeechComponents();
      checkInputComponents();
    }
  }

  void resetTime() {
    emit(SessionState(elapsedTime: 0));
  }

  void pauseGame() {
    emit(state.copyWith(isPaused: true));
  }

  void resumeGame() {
    emit(state.copyWith(isPaused: false));
  }
}
