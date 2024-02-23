import 'tts_controller.dart';
import 'package:audioplayers/audioplayers.dart';

Future<void> narratedAudio() async {
  print('narratedAudio function called');

  String text = "Welcome to PuppyDuck"; // Replace with your own text
  print('Text to be spoken: $text');

  // Create an instance of AudioPlayer
  AudioPlayer audioPlayer = AudioPlayer();

  List<Map<String, dynamic>> timepoints = await speakAndPlay(text);
  print('speakAndPlay function returned: $timepoints');

  // Do something with timepoints
  print('Timepoints: $timepoints');
}
