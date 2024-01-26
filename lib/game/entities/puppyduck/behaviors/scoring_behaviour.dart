import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:pducky/game/entities/puppyduck/ball.dart';
import 'package:pducky/game/cubit/gameplay/scoring_cubit.dart';

class ScoringBehavior extends Behavior {
  final Ball ball;
  final ScoringCubit scoringCubit;

  ScoringBehavior({
    required this.ball,
    required this.scoringCubit,
  });

  void onButtonPressed(String buttonImage) {
    if (scoringCubit.checkScore(buttonImage)) {
      // Increase the score
    }
  }
}
