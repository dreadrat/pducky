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
      TimedFormComponent(startTime: 5, cubit: this),
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
        shouldCheckInputComponents = false;
        gameRef.add(timedFormComponent);
        timedFormComponent.isAdded = true;

        if (shouldCheckInputComponents = true) {
          timedFormComponent.startDistressForm(this);
        }
      } else {}
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
