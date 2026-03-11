// A small repo-local generator for Google TTS + SSML mark timepoints.
//
// Usage:
//   dart run tool/generate_speech.dart \
//     --api-key "$GOOGLE_TTS_API_KEY" \
//     --text "Hi, and welcome to PuppyDuck" \
//     --out assets/audio/speech
//
// Writes:
//   <sanitized>.mp3
//   <sanitized>.json   (timepoints + words)
//   <sanitized>.ssml
//
import 'dart:convert';
import 'dart:io';

import 'package:pducky/tts/google_tts_generator.dart';

String sanitizeFilename(String filename) {
  var sanitized = filename.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  sanitized = sanitized.replaceAll(' ', '_');
  return sanitized;
}

void _usage() {
  stderr.writeln('Usage:');
  stderr.writeln('  dart run tool/generate_speech.dart --api-key <key> --text <text> --out <dir> [--force]');
}

Future<int> main(List<String> args) async {
  String? apiKey;
  String? text;
  String outDir = 'assets/audio/speech';
  var force = false;

  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--api-key':
        apiKey = (i + 1 < args.length) ? args[++i] : null;
        break;
      case '--text':
        text = (i + 1 < args.length) ? args[++i] : null;
        break;
      case '--out':
        outDir = (i + 1 < args.length) ? args[++i] : outDir;
        break;
      case '--force':
        force = true;
        break;
      case '-h':
      case '--help':
        _usage();
        return 0;
    }
  }

  if (apiKey == null || apiKey.trim().isEmpty || text == null || text.trim().isEmpty) {
    _usage();
    return 2;
  }

  final generated = await googleSynthesizeWithTimepoints(
    apiKey: apiKey,
    text: text,
  );

  final sanitized = sanitizeFilename(text);
  final dir = Directory(outDir);
  await dir.create(recursive: true);

  final mp3Path = '${dir.path}/$sanitized.mp3';
  final jsonPath = '${dir.path}/$sanitized.json';
  final ssmlPath = '${dir.path}/$sanitized.ssml';

  if (!force && (File(mp3Path).existsSync() || File(jsonPath).existsSync() || File(ssmlPath).existsSync())) {
    stdout.writeln('Exists, skipping (use --force to overwrite):');
    stdout.writeln('  $mp3Path');
    stdout.writeln('  $jsonPath');
    stdout.writeln('  $ssmlPath');
    return 0;
  }

  await File(mp3Path).writeAsBytes(generated.mp3Bytes);
  await File(jsonPath).writeAsString(const JsonEncoder.withIndent('  ').convert(generated.timepoints));
  await File(ssmlPath).writeAsString(generated.ssml);

  stdout.writeln('Wrote:');
  stdout.writeln('  $mp3Path');
  stdout.writeln('  $jsonPath');
  stdout.writeln('  $ssmlPath');

  return 0;
}
