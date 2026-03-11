import 'package:bloc/bloc.dart';
import 'package:flame/game.dart';
import 'package:pducky/game/cubit/gameplay/session_speaking.dart';
import 'package:pducky/game/timed_form.dart';

class SessionState {
  SessionState({
    required this.elapsedTime,
    this.currentWord = '',
    this.isPaused = false,
    this.thought = '',
  });

  final double elapsedTime;
  final String currentWord;
  final bool isPaused;
  final String thought;

  SessionState copyWith({
    String? currentWord,
    bool? isPaused,
    String? thought,
    double? elapsedTime,
  }) {
    return SessionState(
      elapsedTime: elapsedTime ?? this.elapsedTime,
      currentWord: currentWord ?? this.currentWord,
      isPaused: isPaused ?? this.isPaused,
      thought: thought ?? this.thought,
    );
  }
}

class SessionCubit extends Cubit<SessionState> {
  final FlameGame gameRef;
  List<TimedFormComponent> timedFormComponents = [];
  bool shouldCheckInputComponents = true;

  SessionCubit(this.gameRef, {String currentWord = ''})
      : super(SessionState(elapsedTime: 0, currentWord: currentWord, thought: '')) {
    // Initialize timedFormComponents here
    timedFormComponents = [
      TimedFormComponent(startTime: 5, cubit: this),
    ];
  }

  List<TimedSpeechComponent> timedSpeechComponents = [];
  List<TimedCueComponent> timedCueComponents = [];
  List<TimedLocalSpeech> timedLocalSpeech = [];

  void updateCurrentWord(String word) {
    emit(state.copyWith(currentWord: word));
  }

  void updateThought(String thought) {
    emit(state.copyWith(thought: thought));
  }

  void checkSpeechComponents() {
    final timedSpeechComponentsCopy =
        List<TimedSpeechComponent>.from(timedSpeechComponents);
    for (final timedSpeechComponent in timedSpeechComponentsCopy) {
      if (state.elapsedTime >= timedSpeechComponent.startTime) {
        timedSpeechComponent.speechComponent.start();
        timedSpeechComponents.remove(timedSpeechComponent);
      }
    }
  }

  void checkCueComponents() {
    final timedCueComponentsCopy =
        List<TimedCueComponent>.from(timedCueComponents);
    for (final timedCueComponent in timedCueComponentsCopy) {
      if (state.elapsedTime >= timedCueComponent.startTime) {
        timedCueComponent.cueComponent.start();
        timedCueComponents.remove(timedCueComponent);
      }
    }
  }

  void checkLocalSpeechComponents() {
    final timedLocalSpeechCopy = List<TimedLocalSpeech>.from(timedLocalSpeech);
    for (final timed in timedLocalSpeechCopy) {
      if (state.elapsedTime >= timed.startTime) {
        timed.component.start();
        timedLocalSpeech.remove(timed);
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
      checkCueComponents();
      checkLocalSpeechComponents();
      checkInputComponents();
    }
  }

  void resetTime() {
    emit(state.copyWith(elapsedTime: 0));
  }

  void pauseGame() {
    emit(state.copyWith(isPaused: true));
  }

  void resumeGame() {
    emit(state.copyWith(isPaused: false));
  }
}
