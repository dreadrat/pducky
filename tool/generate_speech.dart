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

import 'package:http/http.dart' as http;

String _textToSSMLWithMarks(String text) {
  final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  final ssmlWords = words.asMap().entries.map((entry) {
    final markName = 'mark${entry.key}';
    return "<mark name='$markName'/>${entry.value}";
  }).join(' ');

  return '<speak>$ssmlWords</speak>';
}

String sanitizeFilename(String filename) {
  var sanitized = filename.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  sanitized = sanitized.replaceAll(' ', '_');
  return sanitized;
}

void _usage() {
  stderr.writeln('Usage:');
  stderr.writeln('  dart run tool/generate_speech.dart --api-key <key> --text <text> --out <dir>');
}

Future<int> main(List<String> args) async {
  String? apiKey;
  String? text;
  String outDir = 'assets/audio/speech';

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

  final ssml = _textToSSMLWithMarks(text);

  final url = Uri.parse('https://texttospeech.googleapis.com/v1beta1/text:synthesize');
  final headers = {
    'Content-Type': 'application/json',
    'X-Goog-Api-Key': apiKey,
  };

  final body = {
    'audioConfig': {
      'audioEncoding': 'MP3',
      'effectsProfileId': ['small-bluetooth-speaker-class-device'],
      'pitch': -8.2,
      'speakingRate': 0.8,
    },
    'input': {'ssml': ssml},
    'voice': {'languageCode': 'en-AU', 'name': 'en-AU-Standard-D'},
    'enableTimePointing': ['SSML_MARK'],
  };

  final resp = await http.post(url, headers: headers, body: jsonEncode(body));
  if (resp.statusCode < 200 || resp.statusCode >= 300) {
    stderr.writeln('TTS failed: HTTP ${resp.statusCode}');
    stderr.writeln(resp.body);
    return 1;
  }

  final jsonData = jsonDecode(resp.body) as Map<String, dynamic>;
  final audioContent = jsonData['audioContent'] as String?;
  final timepoints = (jsonData['timepoints'] as List<dynamic>?);

  if (audioContent == null || timepoints == null) {
    stderr.writeln('Unexpected response (missing audioContent or timepoints).');
    stderr.writeln(resp.body);
    return 1;
  }

  final audioBytes = base64Decode(audioContent);
  final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

  for (var i = 0; i < timepoints.length && i < words.length; i++) {
    (timepoints[i] as Map<String, dynamic>)['word'] = words[i];
  }

  final sanitized = sanitizeFilename(text);
  final dir = Directory(outDir);
  await dir.create(recursive: true);

  final mp3Path = '${dir.path}/$sanitized.mp3';
  final jsonPath = '${dir.path}/$sanitized.json';
  final ssmlPath = '${dir.path}/$sanitized.ssml';

  await File(mp3Path).writeAsBytes(audioBytes);
  await File(jsonPath).writeAsString(const JsonEncoder.withIndent('  ').convert(timepoints));
  await File(ssmlPath).writeAsString(ssml);

  stdout.writeln('Wrote:');
  stdout.writeln('  $mp3Path');
  stdout.writeln('  $jsonPath');
  stdout.writeln('  $ssmlPath');

  return 0;
}
