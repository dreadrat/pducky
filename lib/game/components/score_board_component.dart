import 'package:flame/components.dart';
import 'package:pducky/game/game.dart';

class ScoreBoardComponent extends PositionComponent with HasGameRef<Pducky> { // Add scoringCubit as a field

  ScoreBoardComponent(this.scoringCubit)
      : super(
            anchor: Anchor
                .topCenter,);
  late final TextComponent text;
  final ScoringCubit scoringCubit; // Add scoringCubit as a constructor parameter

  @override
  Future<void> onLoad() async {
    await add(
      text = TextComponent(
        anchor: Anchor.topCenter,
        textRenderer: TextPaint(
          style: gameRef.textStyle
              .copyWith(fontSize: 12), // Set the font size to 12
        ),
      ),
    );
  }

  @override
  void onGameResize(Vector2 size) {
    // TODO: implement onGameResize
    super.onGameResize(size);
    position = Vector2(size.x / 2, 10);
  }

  @override
  void update(double dt) {
    super.update(dt);

    text.text = 'Score: ${scoringCubit.state.score}, '
        'Streak: ${scoringCubit.state.streak}, '
        'Speed: ${scoringCubit.state.speed}'; // Update the text to display the score, streak, and speed
  }
}
