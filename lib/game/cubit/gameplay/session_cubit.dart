import 'package:bloc/bloc.dart';
import 'package:pducky/game/cubit/gameplay/session_speaking.dart';

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
  SessionCubit() : super(SessionState(elapsedTime: 0)) {
    print('SessionCubit initialized');
  }
  List<TimedSpeechComponent> timedSpeechComponents = [];
  void updateCurrentWord(String word) {
    emit(state.copyWith(currentWord: word));
    print('Session Cubit: Updating current word to: $word');
  }

  void checkSpeechComponents() {
    var timedSpeechComponentsCopy =
        List<TimedSpeechComponent>.from(timedSpeechComponents);
    for (var timedSpeechComponent in timedSpeechComponentsCopy) {
      if (state.elapsedTime >= timedSpeechComponent.startTime) {
        print(
            'Starting speech component at time: ${timedSpeechComponent.startTime}');
        timedSpeechComponent.speechComponent.start();
        timedSpeechComponents.remove(timedSpeechComponent);
      }
    }
  }

  void incrementTime(double dt) {
    if (!state.isPaused) {
      final newTime = state.elapsedTime + dt;
      emit(SessionState(elapsedTime: newTime));
      checkSpeechComponents();
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
