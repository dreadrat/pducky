import 'package:flutter_bloc/flutter_bloc.dart';

enum BallImage {
  Puppy,
  Duck,
}

class ScoringCubit extends Cubit<ScoringState> {

  ScoringCubit() : super(initialState);

  static ScoringState initialState = ScoringState(
    ballImage: BallImage.Puppy, 
    ballIsInScoringZone: false,
    score: 0,
    streak: 0,
    wrongTaps: 0,
  );

  void updateBallImage(BallImage image) {
    emit(state.copyWith(ballImage: image));
    print('updateBallImage: $image'); // Add this
  }

  void updateBallInScoringZone(bool isInZone) {
    emit(state.copyWith(ballIsInScoringZone: isInZone));
   
  }

  void increaseScore() {
    emit(state.copyWith(
      score: state.score + 1
    ));
    print('Scored'); 
  }

  void increaseStreak() {
    emit(state.copyWith(
      streak: state.streak + 1
    ));
  }

   void increaseWrongTaps() {
    emit(state.copyWith(wrongTaps: state.wrongTaps + 1));
    resetStreak();
  }

  void resetStreak() {
    emit(state.copyWith(streak: 0));
  }
  bool checkForScore(BallImage buttonImage) {
    if(state.ballImage == buttonImage && state.ballIsInScoringZone) {
      increaseScore();
      increaseStreak();
      return true;
    } else if (state.ballImage != buttonImage && state.ballIsInScoringZone) {
      increaseWrongTaps();
      return false;
    }
    return false;
  }

}

class ScoringState {

  final BallImage ballImage;
  final bool ballIsInScoringZone;
  final int score;
  final int streak;
    final int wrongTaps; 

  const ScoringState({
    required this.ballImage,
    required this.ballIsInScoringZone, 
    required this.score,
    required this.streak,
     required this.wrongTaps, 
  });

  ScoringState copyWith({
    BallImage? ballImage,
    bool? ballIsInScoringZone,
    int? score, 
    int? streak,
    int? wrongTaps,
  }) {

     return ScoringState(
    ballImage: ballImage ?? this.ballImage, 
    ballIsInScoringZone: ballIsInScoringZone ?? this.ballIsInScoringZone,
    score: score ?? this.score,
    streak: streak ?? this.streak,
    wrongTaps: wrongTaps ?? this.wrongTaps,
  );
  
  }
}