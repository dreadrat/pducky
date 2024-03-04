import 'package:flame/components.dart';

import 'package:pducky/game/cubit/cubit.dart';
import 'package:pducky/game/game.dart';

class TimedFormComponent extends Component with HasGameRef<Pducky> {
  TimedFormComponent(
      {required this.startTime, required this.cubit, this.isAdded = false});
  bool isAdded;
  final double startTime;
  final SessionCubit cubit;
  final distressOverlay = 'DistressForm';

  @override
  void onMount() {
    super.onMount();
  }

  void startDistressForm(SessionCubit cubit) {
    print(isAdded);
    if (isAdded) {
      gameRef.overlays.add(distressOverlay);
      gameRef.pauseEngine();
    } else {}
  }

  void updateDistress(SessionCubit cubit) {}
}
