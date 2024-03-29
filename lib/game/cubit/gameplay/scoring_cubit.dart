import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pducky/game/entities/ball/behaviors/bouncing_behaviour.dart';

enum BallImage {
  Puppy,
  Duck,
}

class ScoringCubit extends Cubit<ScoringState> {
  ScoringCubit() : super(initialState);

  static ScoringState initialState = const ScoringState(
    ballImage: BallImage.Puppy,
    ballIsInScoringZone: false,
    score: 0,
    streak: 0,
    missStreak: 0,
    direction: MovementDirection.Left,
    speed: 3000,
    hasTapped: false,
  );

  final StreamController<void> _scoreIncreasedController =
      StreamController<void>();
  final ValueNotifier<Color> scoringZoneColorNotifier =
      ValueNotifier<Color>(Colors.transparent);

  Stream<void> get scoreIncreasedStream => _scoreIncreasedController.stream;

  void updateDirection(MovementDirection direction) {
    emit(state.copyWith(direction: direction));
  }

  void updateBallImage(BallImage image) {
    emit(state.copyWith(ballImage: image));
  }

  void increaseScore(MovementDirection direction) {
    emit(
      state.copyWith(
        score: state.score + 1,
        missStreak: 0,
        hasTapped: true,
        direction: direction,
      ),
    ); // Reset the missed taps count when a score is recorded

    switch (direction) {
      case MovementDirection.Left:
        FlameAudio.play('left_score.mp3');
      case MovementDirection.Right:
        FlameAudio.play('right_score.mp3');
    }

    // Notify listeners that the score has increased
    _scoreIncreasedController.add(null);

    // Change the color of the scoring zone
    scoringZoneColorNotifier.value = Colors.green;
    Future.delayed(const Duration(seconds: 1), () {
      scoringZoneColorNotifier.value = Colors.transparent;
    });
  }

  void increaseStreak() {
    final newStreak = state.streak + 1;

    // If the new streak score is a multiple of 10, speed up the game
    if (newStreak % 10 == 0) {
      speedUpGame();
    }

    emit(state.copyWith(streak: newStreak));
  }

  void wrongTap() {
    emit(
      state.copyWith(
        hasTapped: true,
      ),
    ); // Set hasTapped to true when a wrong tap is recorded

    FlameAudio.play('wrong_tap.mp3');
    resetStreak();
  }

  void speedUpGame() {
    final newSpeed = state.speed - 200;
    FlameAudio.play('speedup.mp3');
    emit(state.copyWith(speed: newSpeed));
  }

  void slowDownGame() {
    final newSpeed = state.speed + 200;
    FlameAudio.play('slowdown.mp3', volume: 0.5);
    emit(state.copyWith(speed: newSpeed));
  }

  void increaseMissedTaps() {
    final newMissStreak = state.missStreak + 1;
    emit(state.copyWith(missStreak: newMissStreak));
    if (newMissStreak % 5 == 0) {
      // Add parentheses around the condition
      slowDownGame();
    }
  }

  Future<void> updateBallInScoringZone(bool isInZone) async {
    if (!isInZone && !state.hasTapped) {
      await Future.delayed(const Duration(milliseconds: 200));
      increaseMissedTaps(); // Increase the missed taps count when the ball leaves the scoring zone and no score has been made
    }
    if (isInZone) {
      emit(
        state.copyWith(
          hasTapped: false,
        ),
      ); // Only reset hasTapped to false when the ball enters the scoring zone
    }
    emit(state.copyWith(ballIsInScoringZone: isInZone));
  }

  void resetStreak() {
    emit(state.copyWith(streak: 0));
  }

  @override
  Future<void> close() {
    _scoreIncreasedController.close();
    return super.close();
  }

  bool checkForScore(BallImage buttonImage) {
    if (state.ballImage == buttonImage && state.ballIsInScoringZone) {
      increaseScore(state.direction); // Use the current direction here
      increaseStreak();
      return true;
    } else if (state.ballImage != buttonImage && state.ballIsInScoringZone) {
      wrongTap();
      return false;
    }
    return false;
  }
}

class ScoringState {
  const ScoringState({
    required this.ballImage,
    required this.ballIsInScoringZone,
    required this.score,
    required this.streak,
    required this.missStreak,
    required this.direction,
    required this.speed,
    required this.hasTapped,
  });
  final BallImage ballImage;
  final bool ballIsInScoringZone;
  final int score;
  final int streak;
  final int missStreak;
  final MovementDirection direction;
  final double speed;
  final bool hasTapped;

  ScoringState copyWith({
    BallImage? ballImage,
    bool? ballIsInScoringZone,
    int? score,
    int? streak,
    int? missStreak,
    MovementDirection? direction,
    double? speed,
    bool? hasTapped,
  }) {
    return ScoringState(
      ballImage: ballImage ?? this.ballImage,
      ballIsInScoringZone: ballIsInScoringZone ?? this.ballIsInScoringZone,
      score: score ?? this.score,
      streak: streak ?? this.streak,

      direction: direction ?? this.direction,
      speed: speed ?? this.speed,
      missStreak: missStreak ?? this.missStreak,
      hasTapped: hasTapped ?? this.hasTapped, // And this
    );
  }
}
