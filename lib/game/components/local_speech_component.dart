import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:pducky/game/cubit/cubit.dart';
import 'package:pducky/game/cubit/gameplay/tts_controller.dart';

/// Generates (if needed) and plays TTS audio from the local filesystem,
/// updating SessionCubit.currentWord in sync with the returned word timepoints.
///
/// This lets us speak full sentences (including the user's current thought)
/// without committing generated assets to git.
class LocalSpeechComponent extends Component {
  LocalSpeechComponent({
    required this.sessionCubit,
    required this.text,
    this.clearAfterSeconds = 1.0,
  });

  final SessionCubit sessionCubit;
  final String text;
  final double clearAfterSeconds;

  final AudioPlayer _player = AudioPlayer();
  List<Map<String, dynamic>> _timepoints = const [];
  int _currentIndex = 0;
  DateTime? _audioStart;
  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    // Generate or load cached local file + timepoints.
    final result = await convertTextToSpeechAndSave(text);
    _timepoints = (result['timepoints'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    final audioFilePath = result['audioFilePath'] as String;
    if (!File(audioFilePath).existsSync()) {
      throw StateError('Expected audio file missing: $audioFilePath');
    }

    if (_timepoints.isNotEmpty) {
      sessionCubit.updateCurrentWord(_timepoints.first['word'] as String);
    }

    await _player.setReleaseMode(ReleaseMode.stop);
    await _player.play(DeviceFileSource(audioFilePath));
    _audioStart = DateTime.now();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_started || _audioStart == null || _timepoints.isEmpty) return;

    final elapsedSeconds =
        DateTime.now().difference(_audioStart!).inMilliseconds / 1000.0;

    if (_currentIndex < _timepoints.length - 1) {
      final nextTime =
          (_timepoints[_currentIndex + 1]['timeSeconds'] as num).toDouble();
      if (elapsedSeconds >= nextTime) {
        _currentIndex++;
        sessionCubit
            .updateCurrentWord(_timepoints[_currentIndex]['word'] as String);
      }
    }

    // Clear after the last word.
    if (_currentIndex == _timepoints.length - 1) {
      // crude: clear after a small delay, once.
      Future.delayed(
        Duration(milliseconds: (clearAfterSeconds * 1000).round()),
        () {
          if (sessionCubit.state.currentWord ==
              (_timepoints.last['word'] as String)) {
            sessionCubit.updateCurrentWord('');
          }
        },
      );
      // Prevent scheduling multiple clears.
      _currentIndex++;
    }
  }

  @override
  Future<void> onRemove() async {
    await _player.stop();
    await _player.dispose();
    super.onRemove();
  }
}
