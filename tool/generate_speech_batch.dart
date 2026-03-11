// Batch generator for Google TTS + SSML mark timepoints.
//
// Usage:
//   dart run tool/generate_speech_batch.dart \
//     --api-key "$GOOGLE_TTS_API_KEY" \
//     --in tool/prompts.txt \
//     --out assets/audio/speech
//
// Prompts file format:
// - one prompt per line
// - blank lines and lines starting with # are ignored
//
// By default, existing outputs are skipped; pass --force to overwrite.

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
  stderr.writeln(
    '  dart run tool/generate_speech_batch.dart --api-key <key> --in <file> --out <dir> [--force]',
  );
}

Future<int> main(List<String> args) async {
  String? apiKey;
  String? inFile;
  var outDir = 'assets/audio/speech';
  var force = false;

  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--api-key':
        apiKey = (i + 1 < args.length) ? args[++i] : null;
        break;
      case '--in':
        inFile = (i + 1 < args.length) ? args[++i] : null;
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

  if (apiKey == null || apiKey.trim().isEmpty || inFile == null || inFile.trim().isEmpty) {
    _usage();
    return 2;
  }

  final promptsPath = inFile;
  final promptsText = await File(promptsPath).readAsString();
  final prompts = promptsText
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty && !l.startsWith('#'))
      .toList();

  if (prompts.isEmpty) {
    stdout.writeln('No prompts found in: $promptsPath');
    return 0;
  }

  final dir = Directory(outDir);
  await dir.create(recursive: true);

  var wrote = 0;
  var skipped = 0;

  for (final text in prompts) {
    final sanitized = sanitizeFilename(text);

    final mp3Path = '${dir.path}/$sanitized.mp3';
    final jsonPath = '${dir.path}/$sanitized.json';
    final ssmlPath = '${dir.path}/$sanitized.ssml';

    if (!force && (File(mp3Path).existsSync() || File(jsonPath).existsSync() || File(ssmlPath).existsSync())) {
      skipped++;
      stdout.writeln('Skip (exists): $sanitized');
      continue;
    }

    try {
      final generated = await googleSynthesizeWithTimepoints(
        apiKey: apiKey,
        text: text,
      );

      await File(mp3Path).writeAsBytes(generated.mp3Bytes);
      await File(jsonPath).writeAsString(const JsonEncoder.withIndent('  ').convert(generated.timepoints));
      await File(ssmlPath).writeAsString(generated.ssml);

      wrote++;
      stdout.writeln('Wrote: $sanitized');
    } catch (e) {
      stderr.writeln('ERROR generating for: $text');
      stderr.writeln(e);
      return 1;
    }
  }

  stdout.writeln('Done. wrote=$wrote skipped=$skipped total=${prompts.length}');
  return 0;
}
