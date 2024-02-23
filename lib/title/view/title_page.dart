import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:pducky/game/game.dart';
import 'package:pducky/l10n/l10n.dart';

class TitlePage extends StatelessWidget {
  const TitlePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const TitlePage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.titleAppBarTitle),
      ),
      body: const SafeArea(child: TitleView()),
    );
  }
}

class TitleView extends StatelessWidget {
  const TitleView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    //FlameAudio.play('intro_title.mp3');

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(l10n.titleDescription),
        Center(
          child: SizedBox(
            width: 250,
            height: 64,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .pushReplacement<void, void>(GamePage.route());
              },
              child: Center(child: Text(l10n.titleButtonStart)),
            ),
          ),
        ),
      ],
    );
  }
}
