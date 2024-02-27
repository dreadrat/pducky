import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:pducky/game/cubit/cubit.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:pducky/game/pducky.dart';
import 'dart:async';
import 'package:flutter/animation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../entities/ball/ball.dart';

final textStyle = TextStyle(
  color: const Color.fromARGB(255, 222, 218, 218),
  fontSize: 32,
);

class SpeechComponent extends PositionComponent with HasGameRef<Pducky> {
  SpeechComponent(
      {required this.sessionCubit,
      required this.filename,
      required this.ball}) {
    loadTimepoints();
  }
  final SessionCubit sessionCubit;
  final PositionComponent ball;
  final String filename;
  List<Map<String, dynamic>> timepoints = [];
  int currentIndex = 0;
  DateTime? audioStartTime; // Add this line
  String? currentWord;
  double wordPosition = 0.0;
  double opacity = 1.0;
  Ticker? fadeOutTicker;

  void start() {
    if (timepoints.isNotEmpty) {
      currentWord = timepoints[0]['word'] as String?;
      sessionCubit.updateCurrentWord(currentWord!);
    }

    // Start the audio playback after a delay of 0.2 seconds
    Future.delayed(Duration(milliseconds: 200), () {
      FlameAudio.play('speech/$filename.mp3').then((_) {});

      audioStartTime = DateTime.now(); // Add this line
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
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    // Update the position of the component based on the new size
    position.y = size.y / 3.5;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Access the Ball instance
    PositionComponent ball = gameRef.puppyDuck;

    position.y = size.y / 3.5;
    // Update the position of the SpeechComponent to match the ball's position
    position.x = ball.position.x;

    // Check if the current time is greater than the timeSeconds of the next word
    if (currentIndex < timepoints.length - 1 &&
        audioStartTime != null &&
        DateTime.now().difference(audioStartTime!).inMilliseconds / 1000 >
            (timepoints[currentIndex + 1]['timeSeconds'] as double)) {
      // Update the current word and slide it to the left
      currentWord = timepoints[++currentIndex]['word'] as String?;
      wordPosition = -1.0;

      // Get the SessionCubit instance and update the currentWord
      sessionCubit.updateCurrentWord(currentWord!);

      // If this is the final word, start a timer to start the fadeOutTicker after 1 second
      if (currentIndex == timepoints.length - 1) {
        Future.delayed(Duration(seconds: 1), () {
          if (fadeOutTicker == null) {
            fadeOutTicker = Ticker((Duration duration) {
              opacity = 1.0 -
                  duration.inMilliseconds / 100.0; // Adjust the speed as needed
              if (opacity <= 0) {
                fadeOutTicker!.stop();
              }
              // Trigger a visual update
            });
            fadeOutTicker!.start();
          }
        });
      }
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw the current word
    if (currentWord != null) {
      double clampedOpacity = opacity.clamp(0.0, 1.0);
      final textSpan = TextSpan(
        text: currentWord,
        style: textStyle.copyWith(
            color: textStyle.color!.withOpacity(clampedOpacity),
            fontSize: gameRef.size.y *
                0.08), // Set the font size to 10% of the game height
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Calculate the position where the text should be rendered
      double xPosition = (wordPosition.clamp(0.0, 1.0) * gameRef.size.x) -
          (textPainter.width / 2);
      double yPosition = gameRef.size.y / 2 - (textPainter.height / 2);

      textPainter.paint(canvas, Offset(xPosition, yPosition));
    }
  }
}
