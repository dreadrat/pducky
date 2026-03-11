import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pducky/game/pducky.dart';

class PauseMenu extends StatelessWidget {
  const PauseMenu({
    required this.gameRef,
    required this.onDismiss,
    super.key,
  });

  final Pducky gameRef;

  /// Called after the pause menu is dismissed, to restore focus to GameWidget.
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            color: const Color(0xFF1E1E1E),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Paused',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Take a breath. When you’re ready you can continue, or set a new thought for this session.',
                    style: TextStyle(color: Colors.white70, height: 1.3),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {
                      gameRef.hidePauseMenu();
                      gameRef.resumeEngine();
                      onDismiss();
                    },
                    child: const Text('Continue'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      // Keep the game paused while the form is open.
                      gameRef.hidePauseMenu();
                      gameRef.showDistressForm();
                      onDismiss();
                    },
                    child: const Text('Set a new thought'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      gameRef.hidePauseMenu();
                      onDismiss();
                    },
                    child: const Text('Close menu'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension _ColorAlpha on Color {
  Color withValues({double? alpha}) {
    if (alpha == null) return this;
    return withAlpha((alpha.clamp(0, 1) * 255).round());
  }
}
