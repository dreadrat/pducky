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

  // Early ramp-up tuning
  static const int _fastRampSpeedUpsMax = 5;
  static const double _fastRampDeltaMs = 300;
  static const double _normalDeltaMs = 200;
  static const int _fastRampBlockSize = 5; // every 5 streak
  static const int _fastRampMaxErrorsPerBlock = 1; // 2 errors disables fast ramp

  int _fastRampSpeedUpsDone = 0;
  int _errorsInCurrentBlock = 0;
  bool _useFastRamp = true;

  static ScoringState initialState = const ScoringState(
    ballImage: BallImage.Puppy,
    ballIsInScoringZone: false,
    score: 0,
    streak: 0,
    missStreak: 0,
    direction: MovementDirection.Left,
    speed: 3000,
    hasTapped: false,
    pendingScoreSoundDirection: null,
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
        // Delay the success sound to the next turnaround blip for better sync.
        pendingScoreSoundDirection: direction,
      ),
    ); // Reset the missed taps count when a score is recorded

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

    // Fast ramp: every 5 streak, speed up by 300ms for the first 5 speed-ups.
    // If the player makes 2+ errors within a 5-streak block, fall back to the
    // normal algorithm.
    if (_useFastRamp && _fastRampSpeedUpsDone < _fastRampSpeedUpsMax) {
      if (newStreak % _fastRampBlockSize == 0) {
        final tooManyErrors =
            _errorsInCurrentBlock > _fastRampMaxErrorsPerBlock;

        if (tooManyErrors) {
          _useFastRamp = false;
        } else {
          _fastRampSpeedUpsDone++;
          _speedUpBy(_fastRampDeltaMs);
        }

        _errorsInCurrentBlock = 0;
      }
    }

    // Normal algorithm (used after fast ramp, or if fast ramp disabled).
    if (!_useFastRamp || _fastRampSpeedUpsDone >= _fastRampSpeedUpsMax) {
      if (newStreak % 10 == 0) {
        speedUpGame();
      }
    }

    emit(state.copyWith(streak: newStreak));
  }

  void wrongTap() {
    if (_useFastRamp && _fastRampSpeedUpsDone < _fastRampSpeedUpsMax) {
      _errorsInCurrentBlock++;
    }

    emit(
      state.copyWith(
        hasTapped: true,
      ),
    ); // Set hasTapped to true when a wrong tap is recorded

    FlameAudio.play('wrong_tap.mp3');
    resetStreak();
  }

  void _speedUpBy(double deltaMs) {
    final newSpeed = state.speed - deltaMs;
    FlameAudio.play('speedup.mp3');
    emit(state.copyWith(speed: newSpeed));
  }

  void speedUpGame() {
    _speedUpBy(_normalDeltaMs);
  }

  void slowDownGame() {
    final newSpeed = state.speed + _normalDeltaMs;
    FlameAudio.play('slowdown.mp3', volume: 0.5);
    emit(state.copyWith(speed: newSpeed));
  }

  void increaseMissedTaps() {
    if (_useFastRamp && _fastRampSpeedUpsDone < _fastRampSpeedUpsMax) {
      _errorsInCurrentBlock++;
    }

    final newMissStreak = state.missStreak + 1;
    emit(state.copyWith(missStreak: newMissStreak));
    if (newMissStreak % 5 == 0) {
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

  void clearPendingScoreSound() {
    if (state.pendingScoreSoundDirection != null) {
      emit(state.copyWith(pendingScoreSoundDirection: null));
    }
  }

  MovementDirection? consumePendingScoreSoundDirection() {
    final pending = state.pendingScoreSoundDirection;
    if (pending != null) {
      emit(state.copyWith(pendingScoreSoundDirection: null));
    }
    return pending;
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
  static const _unset = Object();

  const ScoringState({
    required this.ballImage,
    required this.ballIsInScoringZone,
    required this.score,
    required this.streak,
    required this.missStreak,
    required this.direction,
    required this.speed,
    required this.hasTapped,
    required this.pendingScoreSoundDirection,
  });
  final BallImage ballImage;
  final bool ballIsInScoringZone;
  final int score;
  final int streak;
  final int missStreak;
  final MovementDirection direction;
  final double speed;
  final bool hasTapped;

  /// When set, play the corresponding success sound at the next turnaround.
  final MovementDirection? pendingScoreSoundDirection;

  ScoringState copyWith({
    BallImage? ballImage,
    bool? ballIsInScoringZone,
    int? score,
    int? streak,
    int? missStreak,
    MovementDirection? direction,
    double? speed,
    bool? hasTapped,
    Object? pendingScoreSoundDirection = _unset,
  }) {
    return ScoringState(
      ballImage: ballImage ?? this.ballImage,
      ballIsInScoringZone: ballIsInScoringZone ?? this.ballIsInScoringZone,
      score: score ?? this.score,
      streak: streak ?? this.streak,
      direction: direction ?? this.direction,
      speed: speed ?? this.speed,
      missStreak: missStreak ?? this.missStreak,
      hasTapped: hasTapped ?? this.hasTapped,
      pendingScoreSoundDirection: pendingScoreSoundDirection == _unset
          ? this.pendingScoreSoundDirection
          : pendingScoreSoundDirection as MovementDirection?,
    );
  }
}
