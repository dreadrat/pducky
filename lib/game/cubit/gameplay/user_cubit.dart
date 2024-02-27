import 'package:bloc/bloc.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit()
      : super(UserState(thought: '', distressLevel: 0, sessionDetails: []));

  void updateDistressLevel(int level) {
    emit(UserState(
      thought: state.thought,
      distressLevel: level,
      sessionDetails: state.sessionDetails,
    ));
  }

  void addSession(Session session) {
    emit(UserState(
      thought: state.thought,
      distressLevel: state.distressLevel,
      sessionDetails: List.from(state.sessionDetails)..add(session),
    ));
  }
}

class UserState {
  final String thought;
  final int distressLevel;
  final List<Session> sessionDetails;

  UserState(
      {required this.thought,
      required this.distressLevel,
      required this.sessionDetails});
}

class Session {
  final DateTime date;
  final int duration;
  final List<int> distressLevels;
  final String thought;

  Session(
      {required this.date,
      required this.duration,
      required this.distressLevels,
      required this.thought});
}
