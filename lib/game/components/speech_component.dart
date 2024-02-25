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

final textStyle = TextStyle(
  color: Colors.black,
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
  DateTime? audioStartTime; // Add this line
  String? currentWord;
  double wordPosition = 0.0;
  double opacity = 1.0;
  Ticker? fadeOutTicker;
  bool isAudioPlaying = false;

  void start() {
    if (timepoints.isNotEmpty) {
      currentWord = timepoints[0]['word'] as String?;
      sessionCubit.updateCurrentWord(currentWord!);
    }
    print(timepoints[0]['word']);
    // Start the audio playback after a delay of 0.2 seconds
    Future.delayed(Duration(milliseconds: 200), () {
      FlameAudio.play('speech/$filename.mp3').then((_) {
        isAudioPlaying = false;
      });

      isAudioPlaying = true;
      audioStartTime = DateTime.now(); // Add this line
    });
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

      print('SpeechComponent currentWord: $currentWord');
      print('SessionCubit currentWord: ${sessionCubit.state.currentWord}');
    }

    // Slide the word to the right
    if (wordPosition < 0) {
      wordPosition += dt * 10; // Adjust the speed as needed
    }

    // Fade out the entire phrase after the audio finishes playing
    if (!isAudioPlaying && fadeOutTicker == null) {
      fadeOutTicker = Ticker((Duration duration) {
        opacity =
            1.0 - duration.inMilliseconds / 100.0; // Adjust the speed as needed
        if (opacity <= 0) {
          fadeOutTicker!.stop();
        }
      });
      fadeOutTicker!.start();
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
            color: textStyle.color!.withOpacity(clampedOpacity)),
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