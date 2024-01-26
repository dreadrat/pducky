import 'package:flutter_bloc/flutter_bloc.dart';

class ScoringState {
  final String ballImage;
  final bool ballIsInScoringZone;
  final int score;

  ScoringState({
    required this.ballImage,
    required this.ballIsInScoringZone,
    required this.score,
  });
}

class ScoringCubit extends Cubit<ScoringState> {
  ScoringCubit()
      : super(
            ScoringState(ballImage: '', ballIsInScoringZone: false, score: 0));

  void updateBallImage(String newImage) {
    emit(ScoringState(
        ballImage: newImage,
        ballIsInScoringZone: state.ballIsInScoringZone,
        score: state.score));
  }

  void updateBallIsInScoringZone(bool isInScoringZone) {
    emit(ScoringState(
        ballImage: state.ballImage,
        ballIsInScoringZone: isInScoringZone,
        score: state.score));
  }

  void increaseScore() {
    emit(ScoringState(
        ballImage: state.ballImage,
        ballIsInScoringZone: state.ballIsInScoringZone,
        score: state.score + 1));
  }

  bool checkScore(String buttonImage) {
    if (state.ballImage == buttonImage && state.ballIsInScoringZone) {
      increaseScore();
      return true;
    }
    return false;
  }
}
