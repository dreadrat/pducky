import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:pducky/game/cubit/cubit.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:pducky/game/pducky.dart';

final textStyle = TextStyle(
  color: const Color.fromARGB(255, 248, 248, 248),
  fontSize: 24,
);

class SpeechComponent extends PositionComponent with HasGameRef<Pducky> {
  SpeechComponent({
    required this.sessionCubit,
    required this.filename,
  }) {
    loadTimepoints();
  }
  final SessionCubit sessionCubit;
  final String filename;
  List<Map<String, dynamic>> timepoints = [];
  int currentIndex = 0;
  String? currentWord;

  void start() {
    if (timepoints.isNotEmpty) {
      currentWord = timepoints[0]['word'] as String?;
    }
    print(timepoints[0]['word']);
    // Start the audio playback after a delay of 0.2 seconds
    Future.delayed(Duration(milliseconds: 200), () {
      FlameAudio.play('speech/$filename.mp3');
    });
  }

  Future<void> loadTimepoints() async {
    // Load the JSON file
    String fileContents =
        await rootBundle.loadString('assets/audio/speech/$filename.json');

    // Parse the timepoints list
    List<dynamic> decodedJson = jsonDecode(fileContents) as List<dynamic>;
    timepoints =
        decodedJson.map((item) => item as Map<String, dynamic>).toList();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update the current word
    if (currentIndex < timepoints.length) {
      currentWord = timepoints[currentIndex]['word'] as String?;
      sessionCubit.updateCurrentWord(currentWord!);
      currentIndex++;
    }
  }

  @override
  void render(Canvas canvas) {
    // Clear the canvas
    canvas.drawRect(
      Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y),
      Paint()..color = Colors.transparent,
    );

    // Draw the current word from sessionCubit
    if (sessionCubit.state.currentWord != null) {
      final textSpan = TextSpan(
        text: sessionCubit.state.currentWord,
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Calculate the position where the text should be rendered
      double xPosition = gameRef.size.x / 2 - (textPainter.width / 2);
      double yPosition = gameRef.size.y / 2 - (textPainter.height / 2);

      textPainter.paint(canvas, Offset(xPosition, yPosition));
    }
  }
}
