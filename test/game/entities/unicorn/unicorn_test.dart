// ignore_for_file: cascade_invocations

import 'package:audioplayers/audioplayers.dart';
import 'package:flame/extensions.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pducky/game/entities/puppyduck/behaviors/behaviors.dart';
import 'package:pducky/game/game.dart';
import 'package:pducky/l10n/l10n.dart';

class _MockAppLocalizations extends Mock implements AppLocalizations {}

class _MockAudioPlayer extends Mock implements AudioPlayer {}

class _Pducky extends Pducky {
  _Pducky({
    required super.l10n,
    required super.effectPlayer,
    required super.textStyle,
  });

  @override
  Future<void> onLoad() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final l10n = _MockAppLocalizations();
  _Pducky createFlameGame() {
    return _Pducky(
      l10n: l10n,
      effectPlayer: _MockAudioPlayer(),
      textStyle: const TextStyle(),
    );
  }

  group('Unicorn', () {
    setUp(() {
      when(() => l10n.counterText(any())).thenReturn('counterText');
    });

    testWithGame(
      'loads correctly',
      createFlameGame,
      (game) async {
        final unicorn = PuppyDuck(position: Vector2.all(1));
        await game.ensureAdd(unicorn);
      },
    );

    group('animation', () {
      testWithGame(
        'plays animation',
        createFlameGame,
        (game) async {
          final unicorn = PuppyDuck.test(position: Vector2.all(1));
          await game.ensureAdd(unicorn);
        },
      );

      testWithGame(
        'reset animation back to frame one and stops it',
        createFlameGame,
        (game) async {
          final unicorn = PuppyDuck.test(position: Vector2.all(1));
          await game.ensureAdd(unicorn);
        },
      );
    });
  });
}
