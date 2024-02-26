import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BallTextArea extends TextBoxComponent {
  BallTextArea(String text)
      : super(
          text: text,
          textRenderer: regular,
          boxConfig: TextBoxConfig(),
        );

  final bgPaint = Paint()..color = Color(0xFFFF00FF);
  final borderPaint = Paint()
    ..color = Color(0xFF000000)
    ..style = PaintingStyle.stroke;

  @override
  void render(Canvas canvas) {
    Rect rect = Rect.fromLTWH(0, 0, width, height);
    canvas.drawRect(rect, bgPaint);
    super.render(canvas);
  }
}

final regular = TextPaint(
  style: TextStyle(
    fontSize: 38.0,
    color: Colors.white,
    backgroundColor: Colors.grey,
  ),
);
