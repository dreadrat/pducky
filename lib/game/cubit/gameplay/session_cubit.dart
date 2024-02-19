import 'package:bloc/bloc.dart';

class SessionState {
  SessionState({required this.elapsedTime, this.currentWord = ''});

  final double elapsedTime;
  final String currentWord;

  SessionState copyWith({String? currentWord}) {
    return SessionState(
      elapsedTime: elapsedTime,
      currentWord: currentWord ?? this.currentWord,
    );
  }
}

class SessionCubit extends Cubit<SessionState> {
  SessionCubit() : super(SessionState(elapsedTime: 0));

  void updateCurrentWord(String word) {
    emit(state.copyWith(currentWord: word));
  }

  void incrementTime(double dt) {
    final newTime = state.elapsedTime + dt;
    emit(SessionState(elapsedTime: newTime));
  }

  void resetTime() {
    emit(SessionState(elapsedTime: 0));
  }
}
