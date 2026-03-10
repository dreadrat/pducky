import 'package:flame/components.dart';
import 'package:pducky/game/components/button_component.dart';
import 'package:pducky/game/components/pause_component.dart';
import 'package:pducky/game/cubit/gameplay/scoring_cubit.dart';

class GameplayButtons extends PositionComponent with HasGameRef {
  // Add this

  GameplayButtons({required this.scoringCubit});
  final ScoringCubit scoringCubit; // Add this

  @override
  Future<void> onLoad() async {
    await addAll([
      GameButton(
        scoringCubit: scoringCubit, // Add this argument
        position: Vector2.zero(),
        side: ButtonSide.Left,
        image: ButtonImage.Puppy,
        keyHint: 'Z',
        onTap: () {},
      ),
      GameButton(
        scoringCubit: scoringCubit,
        position: Vector2.zero(),
        side: ButtonSide.Left,
        image: ButtonImage.Duck,
        keyHint: 'A',
        onTap: () {},
      ),
      GameButton(
        scoringCubit: scoringCubit,
        position: Vector2.zero(),
        side: ButtonSide.Right,
        image: ButtonImage.Duck,
        keyHint: 'K',
        onTap: () {},
      ),
      GameButton(
        scoringCubit: scoringCubit,
        position: Vector2.zero(),
        side: ButtonSide.Right,
        image: ButtonImage.Puppy,
        keyHint: 'M',
        onTap: () {},
      ),
      PauseButtonComponent()
    ]);
  }
}
