library;

import 'dart:convert';

import 'package:http/http.dart' as http;

class GeneratedSpeech {
  GeneratedSpeech({
    required this.ssml,
    required this.mp3Bytes,
    required this.timepoints,
  });

  final String ssml;
  final List<int> mp3Bytes;

  /// Each timepoint typically contains: {"markName": "mark0", "timeSeconds": 0.12, "word": "Hi"}
  final List<Map<String, dynamic>> timepoints;
}

String textToSSMLWithMarks(String text) {
  final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  final ssmlWords = words.asMap().entries.map((entry) {
    final markName = 'mark${entry.key}';
    return "<mark name='$markName'/>${entry.value}";
  }).join(' ');

  return '<speak>$ssmlWords</speak>';
}

Future<GeneratedSpeech> googleSynthesizeWithTimepoints({
  required String apiKey,
  required String text,
  String languageCode = 'en-AU',
  String voiceName = 'en-AU-Standard-D',
  double pitch = -8.2,
  double speakingRate = 0.8,
}) async {
  final ssml = textToSSMLWithMarks(text);

  final url = Uri.parse('https://texttospeech.googleapis.com/v1beta1/text:synthesize');
  final headers = {
    'Content-Type': 'application/json',
    'X-Goog-Api-Key': apiKey,
  };

  final body = {
    'audioConfig': {
      'audioEncoding': 'MP3',
      'effectsProfileId': ['small-bluetooth-speaker-class-device'],
      'pitch': pitch,
      'speakingRate': speakingRate,
    },
    'input': {'ssml': ssml},
    'voice': {'languageCode': languageCode, 'name': voiceName},
    'enableTimePointing': ['SSML_MARK'],
  };

  final response = await http.post(url, headers: headers, body: jsonEncode(body));
  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw StateError(
      'Google TTS failed: HTTP ${response.statusCode}: ${response.body}',
    );
  }

  final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
  final audioContent = jsonData['audioContent'] as String?;
  final rawTimepoints = jsonData['timepoints'] as List<dynamic>?;
  if (audioContent == null || rawTimepoints == null) {
    throw StateError('Unexpected Google TTS response (missing audioContent/timepoints).');
  }

  final mp3Bytes = base64Decode(audioContent);

  final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  final timepoints = rawTimepoints
      .map((e) => (e as Map).cast<String, dynamic>())
      .toList(growable: false);

  for (var i = 0; i < timepoints.length && i < words.length; i++) {
    timepoints[i]['word'] = words[i];
  }

  return GeneratedSpeech(ssml: ssml, mp3Bytes: mp3Bytes, timepoints: timepoints);
}
