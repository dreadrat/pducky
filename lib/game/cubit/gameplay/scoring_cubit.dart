import 'package:flame_audio/flame_audio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pducky/game/entities/ball/behaviors/bouncing_behaviour.dart';

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
    direction: MovementDirection.Left,
  );


  void updateDirection(MovementDirection direction) {
    emit(state.copyWith(direction: direction));
  }
  void updateBallImage(BallImage image) {
    emit(state.copyWith(ballImage: image));
    print('updateBallImage: $image'); // Add this
  }

  void updateBallInScoringZone(bool isInZone) {
    emit(state.copyWith(ballIsInScoringZone: isInZone));
   
  }

  void increaseScore(MovementDirection direction) {
    emit(state.copyWith(
      score: state.score + 1
    ));

    switch (direction) {
      case MovementDirection.Left:
        FlameAudio.play('score_left.mp3');
        break;
      case MovementDirection.Right:
        FlameAudio.play('score_right.mp3');
        break;
    }
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
      increaseScore(state.direction); // Use the current direction here
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
    final MovementDirection direction;

  const ScoringState({
    required this.ballImage,
    required this.ballIsInScoringZone, 
    required this.score,
    required this.streak,
     required this.wrongTaps, 
     required this.direction,
  });

  ScoringState copyWith({
    BallImage? ballImage,
    bool? ballIsInScoringZone,
    int? score, 
    int? streak,
    int? wrongTaps,
    MovementDirection? direction, 
     }) {

     return ScoringState(
    ballImage: ballImage ?? this.ballImage, 
    ballIsInScoringZone: ballIsInScoringZone ?? this.ballIsInScoringZone,
    score: score ?? this.score,
    streak: streak ?? this.streak,
    wrongTaps: wrongTaps ?? this.wrongTaps,
    direction: direction ?? this.direction, // And this

  );
  
  }
}