import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pducky/tts/google_tts_generator.dart';
import 'package:pducky/tts/tts_config.dart';

// Converting the text input to audio and SSML markup with timestamps

StreamController<String> wordStreamController = StreamController<String>();
AudioPlayer audioPlayer = AudioPlayer();

Future<Map<String, dynamic>> convertTextToSpeechAndSave(String text) async {
  print('Starting to convert text to speech');
  print('$text');

  if (!hasGoogleTtsApiKey) {
    throw StateError(
      'Missing GOOGLE_TTS_API_KEY. Provide it via --dart-define or '
      '--dart-define-from-file (see lib/tts/tts_config.dart).',
    );
  }

  final generated = await googleSynthesizeWithTimepoints(
    apiKey: googleTtsApiKey,
    text: text,
  );

  final ssml = generated.ssml;
  final audioBytes = generated.mp3Bytes;
  final timepoints = generated.timepoints;

// Get the path of the directory where you want to save the file
  final docDir = await getApplicationDocumentsDirectory();
  final dirPath = '${docDir.path}${Platform.pathSeparator}speech_outputs';
  await Directory(dirPath).create(recursive: true);

  /// Sanitize the filename
  final sanitizedText = sanitizeFilename(text);
  final audioFilePath = '$dirPath${Platform.pathSeparator}$sanitizedText.mp3';
  final ssmlFilePath = '$dirPath${Platform.pathSeparator}$sanitizedText.ssml';
  final jsonFilePath = '$dirPath${Platform.pathSeparator}$sanitizedText.json';

  print('Audio file path set to: $audioFilePath');
  print('SSML file path set to: $ssmlFilePath');
  print('JSON file path set to: $jsonFilePath');

  // Create a new file at the desired path for the audio
  File audioFile = File(audioFilePath);

  // Write the audio bytes to the file
  await audioFile.writeAsBytes(audioBytes);
  print('Audio file written successfully');

  // Create a new file at the desired path for the SSML
  File ssmlFile = File(ssmlFilePath);

  // Write the SSML markup to the file
  await ssmlFile.writeAsString(ssml);

  // Write timepoints to a dedicated JSON file (same format SpeechComponent uses)
  final jsonFile = File(jsonFilePath);
  await jsonFile.writeAsString(jsonEncode(timepoints));

  print('Speech files written successfully');
  return {
    'timepoints': timepoints,
    'audioFilePath': audioFilePath,
    'jsonFilePath': jsonFilePath,
  };
}

//Speak and Play the audio

Future<List<Map<String, dynamic>>> speakAndPlay(
  String text,
) async {
  print('Starting to speak and play');

  // Get the path of the directory where you're saving the file in the `speakMe` function
  Directory docDir = await getApplicationDocumentsDirectory();
  final dirPath = '${docDir.path}${Platform.pathSeparator}speech_outputs';

  // Sanitize the filename
  final sanitizedText = sanitizeFilename(text);
  final filePath = '$dirPath${Platform.pathSeparator}$sanitizedText.mp3';

  File audioFile = File(filePath);

  Map<String, dynamic> result;
  if (await audioFile.exists()) {
    print('File already exists, playing existing file');

    final jsonFilePath = '$dirPath${Platform.pathSeparator}$sanitizedText.json';

    List<Map<String, dynamic>> timepoints;
    final jsonFile = File(jsonFilePath);
    if (await jsonFile.exists()) {
      final content = await jsonFile.readAsString();
      timepoints = List<Map<String, dynamic>>.from(
        jsonDecode(content) as List<dynamic>,
      );
    } else {
      // Fallback for older outputs that embedded timepoints inside the .ssml file
      final ssmlFilePath =
          '$dirPath${Platform.pathSeparator}$sanitizedText.ssml';
      final ssmlContent = await File(ssmlFilePath).readAsString();

      final timepointsRegExp = RegExp(r'Timepoints: (\[.*\])');
      final timepointsMatch = timepointsRegExp.firstMatch(ssmlContent);
      final timepointsContent =
          timepointsMatch != null ? timepointsMatch.group(1)! : '';

      timepoints = timepointsContent.isNotEmpty
          ? List<Map<String, dynamic>>.from(
              jsonDecode(timepointsContent) as List<dynamic>,
            )
          : [];
    }

    result = {
      'audioFilePath': filePath,
      'timepoints': timepoints,
      // You might want to read the timepoints from the existing file here
    };
  } else {
    print('File does not exist, creating new file');
    result = await convertTextToSpeechAndSave(text);
  }

  await audioPlayer.setSource(DeviceFileSource(filePath));

  // Get the timepoints
  List<dynamic> timepoints = result['timepoints'] as List<dynamic>;

  Timer? timer;
  int milliseconds = 0;

  audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
    if (state == PlayerState.playing) {
      // Check if the first word's timepoint is less than 50 milliseconds
      num? firstTimepoint =
          timepoints[0]['timeSeconds'] * 1000 as num; // convert to milliseconds
      if (firstTimepoint != null && firstTimepoint < 50) {
        wordStreamController.add(timepoints[0]['word'] as String);
      }

      // Start the timer
      timer = Timer.periodic(Duration(milliseconds: 50), (Timer t) {
        milliseconds += 50;
        if (timepoints.isEmpty) {
          print('No timepoints found');
          return;
        }

        for (int i = 0; i < timepoints.length; i++) {
          num? timepoint = timepoints[i]['timeSeconds'] * 1000
              as num; // convert to milliseconds
          if (timepoint != null && milliseconds < timepoint) {
            wordStreamController.add(timepoints[i]['word'] as String);
            break;
          }
        }
      });
    } else if (state == PlayerState.stopped || state == PlayerState.paused) {
      timer?.cancel();
      wordStreamController.close();
    }
  });

  print('Resuming audio player');
  await audioPlayer.resume();

  print('Finished speaking and playing');

  // Return the timepoints
  return timepoints.cast<Map<String, dynamic>>();
}

String sanitizeFilename(String filename) {
  // Replace invalid characters with an underscore
  String sanitized = filename.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  // Replace spaces with an underscore
  sanitized = sanitized.replaceAll(' ', '_');
  return sanitized;
}

List<Map<String, dynamic>> extractTimepoints(
    String ssmlContent, String timepointsContent) {
  print('SSML content: $ssmlContent'); // Log the SSML content
  print('Timepoints content: $timepointsContent'); // Log the timepoints content

  RegExp markRegExp = RegExp(r"<mark name='(mark\d+)'\/>");
  Iterable<Match> matches = markRegExp.allMatches(ssmlContent);

  List<Map<String, dynamic>> timepointsContentList =
      List<Map<String, dynamic>>.from(
          jsonDecode(timepointsContent) as List<dynamic>);

  // Ensure keys in timepointsContentList are properly formatted
  timepointsContentList = timepointsContentList.map((timepoint) {
    return timepoint.map((key, value) {
      return MapEntry('"' + key + '"', value);
    });
  }).toList();

  List<Map<String, dynamic>> timepoints = [];
  for (Match match in matches) {
    String markName = match.group(1)!;
    print('Mark name: $markName'); // Log the mark name

    Map<String, dynamic>? timepoint =
        extractTimepoint(timepointsContentList, markName);
    print('Extracted timepoint: $timepoint'); // Log the extracted timepoint

    if (timepoint != null) {
      timepoints.add(timepoint);
    }
  }

  print('Extracted timepoints: $timepoints'); // Log the extracted timepoints
  return timepoints;
}

Map<String, dynamic>? extractTimepoint(
    List<Map<String, dynamic>> timepointsContent, String markName) {
  for (var timepoint in timepointsContent) {
    if (timepoint['markName'] == markName) {
      return timepoint;
    }
  }
  print('No match found for mark name'); // Log that no match was found
  return null;
}
