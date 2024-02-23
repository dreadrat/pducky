import 'package:flutter_bloc/flutter_bloc.dart';
import 'session_cubit.dart';
import 'package:audioplayers/audioplayers.dart';
import 'tts_controller.dart';

class AudioController {
  final SessionCubit sessionCubit;
  final AudioPlayer audioPlayer;

  AudioController({required this.sessionCubit, required this.audioPlayer});

  Future<void> playPhrases(List<Map<String, dynamic>> phrases) async {
    for (var phrase in phrases) {
      // Get the start time and text from the phrase
      double startTime = phrase['startTime'] as double;
      String text = phrase['text'] as String;

      // Wait until the start time
      await Future.delayed(Duration(milliseconds: (startTime * 1000).round()));

      // Use the speakAndPlay function to play the audio and get the timepoints
      List<Map<String, dynamic>> timepoints = await speakAndPlay(text);

      // Use the SessionCubit to update the current word
      for (var timepoint in timepoints) {
        String word = timepoint['word'] as String;
        sessionCubit.updateCurrentWord(word);
        print('$word');

        // Wait until the next word
        if (timepoints.indexOf(timepoint) < timepoints.length - 1) {
          double nextTime = timepoints[timepoints.indexOf(timepoint) + 1]
              ['timeSeconds'] as double;
          double currentTime = timepoint['timeSeconds'] as double;
          await Future.delayed(Duration(
              milliseconds: ((nextTime - currentTime) * 1000).round()));
        }
      }
    }
  }
}
