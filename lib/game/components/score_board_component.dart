import 'package:flame/components.dart';
import 'package:pducky/game/cubit/gameplay/scoring_cubit.dart';
import 'package:pducky/game/game.dart';

class ScoreBoardComponent extends PositionComponent with HasGameRef<Pducky> {
  late final TextComponent text;
  final ScoringCubit scoringCubit; // Add scoringCubit as a field

  ScoreBoardComponent(this.scoringCubit)
      : super(
            anchor: Anchor
                .topCenter); // Add scoringCubit as a constructor parameter

  @override
  Future<void> onLoad() async {
    await add(
      text = TextComponent(
        anchor: Anchor.topCenter,
        textRenderer: TextPaint(
          style: gameRef.textStyle,
        ),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    text.text =
        'Score: ${scoringCubit.state.score}'; // Use scoringCubit to get the score
    position =
        gameRef.size / 2; // Update the position to the center of the screen
  }
}
