import 'package:flame/components.dart';
// Speech playback is handled via a shared AudioPlayer to prevent overlaps.
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:pducky/game/cubit/cubit.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:pducky/game/pducky.dart';
import 'dart:async';
import 'package:flutter/animation.dart';
import 'package:flutter/scheduler.dart';

final textStyle = TextStyle(
  color: const Color.fromARGB(255, 222, 218, 218),
  fontSize: 32,
);

class SpeechComponent extends PositionComponent with HasGameRef<Pducky> {
  static final AudioPlayer _player = AudioPlayer();
  static StreamSubscription<void>? _completeSub;

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
  bool _endScheduled = false;
  bool _ended = false;

  Future<void> start() async {
    sessionCubit.setSpeaking(true);
    _endScheduled = false;
    _ended = false;

    if (timepoints.isNotEmpty) {
      currentWord = timepoints[0]['word'] as String?;
      sessionCubit.updateCurrentWord(currentWord!);
    }

    // Stop any previous speech to avoid overlaps, then play this one.
    await _player.stop();
    await _completeSub?.cancel();
    _completeSub = _player.onPlayerComplete.listen((_) {
      sessionCubit.setSpeaking(false);
      sessionCubit.updateCurrentWord('');
    });

    audioStartTime = DateTime.now();
    await _player.play(AssetSource('assets/audio/speech/$filename.mp3'));
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

    // Backstop: once we've passed the final timepoint, end speech.
    if (!_ended && _endScheduled && audioStartTime != null && timepoints.isNotEmpty) {
      final elapsedSeconds =
          DateTime.now().difference(audioStartTime!).inMilliseconds / 1000.0;
      final lastTime = (timepoints.last['timeSeconds'] as num).toDouble();
      if (elapsedSeconds >= lastTime + 0.4) {
        _ended = true;
        sessionCubit.setSpeaking(false);
        // Clear the guided word so the thought can show between lines.
        sessionCubit.updateCurrentWord('');
      }
    }

    // Access the Ball instance
    PositionComponent ball = gameRef.puppyDuck;

    position.y = size.y / 3.5;
    // Update the position of the SpeechComponent to match the ball's position
    position.x = ball.position.x;

    // Check if the current time is greater than the timeSeconds of the next word

    if (currentIndex < timepoints.length - 1 &&
        audioStartTime != null &&
        DateTime.now().difference(audioStartTime!).inMilliseconds / 1000 >
            (timepoints[currentIndex + 1]['timeSeconds'] as num).toDouble()) {
      // Update the current word and slide it to the left
      currentWord = timepoints[++currentIndex]['word'] as String?;
      wordPosition = -1.0;

      // Get the SessionCubit instance and update the currentWord
      sessionCubit.updateCurrentWord(currentWord!);

      // If this is the final word, schedule an end-of-speech signal.
      //
      // We use an absolute time check in update() as a backstop, because relying
      // only on a fade-out ticker can leave isSpeaking stuck true.
      if (currentIndex == timepoints.length - 1) {
        _endScheduled = true;
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
