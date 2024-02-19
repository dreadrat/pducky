import 'package:bloc/bloc.dart';

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
  SessionCubit() : super(SessionState(elapsedTime: 0));

  void updateCurrentWord(String word) {
    emit(state.copyWith(currentWord: word));
  }

  void incrementTime(double dt) {
    if (!state.isPaused) {
      final newTime = state.elapsedTime + dt;
      emit(SessionState(elapsedTime: newTime));
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
