import 'dart:async' as async;

import 'package:flame/components.dart';
import 'package:pducky/game/cubit/cubit.dart';

/// A lightweight, text-only cue.
///
/// This is used for timed clinical prompts without requiring pre-generated
/// audio/timepoints.
class CueComponent extends Component {
  CueComponent({
    required this.sessionCubit,
    required this.text,
    this.displaySeconds = 2.0,
  });

  final SessionCubit sessionCubit;
  final String text;
  final double displaySeconds;

  async.Timer? _timer;

  void start() {
    sessionCubit.updateCurrentWord(text);
    _timer?.cancel();
    _timer = async.Timer(
      Duration(milliseconds: (displaySeconds * 1000).round()),
      () {
      // Only clear if we are still showing this cue.
      if (sessionCubit.state.currentWord == text) {
        sessionCubit.updateCurrentWord('');
      }
      },
    );
  }

  @override
  void onRemove() {
    _timer?.cancel();
    super.onRemove();
  }
}
