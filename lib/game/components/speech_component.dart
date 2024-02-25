import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:pducky/game/cubit/cubit.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:xml/xml.dart' as xml;
import 'package:xml/xml_events.dart';
import 'package:pducky/game/pducky.dart';

class SpeechComponent extends Component with HasGameRef<Pducky> {
  final SessionCubit sessionCubit;
  final String filename;
  List<Map<String, dynamic>> timepoints = [];
  int currentIndex = 0;
  DateTime? audioStartTime; // Add this line

  SpeechComponent({
    required this.sessionCubit,
    required this.filename,
  }) {
    loadTimepoints();
  }

  Future<void> loadTimepoints() async {
    print('Loading timepoints...');

    // Load the JSON file
    String fileContents =
        await rootBundle.loadString('assets/audio/speech/$filename.json');
    print('File loaded.');

    // Parse the timepoints list
    List<dynamic> decodedJson = jsonDecode(fileContents) as List<dynamic>;
    timepoints =
        decodedJson.map((item) => item as Map<String, dynamic>).toList();
    print('Timepoints extracted: $timepoints');
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Check if the game is paused
    if (sessionCubit.state.isPaused) {
      print('Game is paused.');
      return;
    }

    // Check if timepoints is initialized
    if (timepoints == null) {
      print('Timepoints is not initialized yet.');
      return;
    }

    // Check if it's time to highlight the next word
    if (currentIndex < timepoints.length &&
        timepoints[currentIndex]['timeSeconds'] != null &&
        audioStartTime != null && // Make sure the audio has started playing
        DateTime.now().difference(audioStartTime!).inSeconds >=
            (timepoints[currentIndex]['timeSeconds'] as num)) {
      print('Time to highlight the next word.');
      currentIndex++;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Render the current, previous, and next words
    // This is just a placeholder, you'll need to implement this
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: currentIndex < timepoints.length
            ? timepoints[currentIndex]['word'] as String
            : '',
        style: TextStyle(color: Colors.white, fontSize: 28.0),
      ),
      textDirection: TextDirection.ltr,
    );

    // Layout the text
    textPainter.layout();

    // Calculate the center position of the game viewport
    Vector2 center = gameRef.size / 2;

    // Calculate the position of the text so that it's centered
    double x = center.x - textPainter.width / 2;
    double y = center.y - textPainter.height / 2;
    Offset textPosition = Offset(x, y);

    // Draw the text
    textPainter.paint(canvas, textPosition);

    print(
        'Rendering word: ${currentIndex < timepoints.length ? timepoints[currentIndex]['word'] as String : ''}');
  }

  void start() {
    // Start the audio playback
    print('Starting audio playback...');
    FlameAudio.play('speech/$filename.mp3');
    audioStartTime =
        DateTime.now(); // Set the start time when the audio starts playing
  }
}
