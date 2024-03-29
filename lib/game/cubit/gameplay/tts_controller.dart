import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flame_audio/flame_audio.dart';

//Converting the text input to audio and SSML markup with timestamps

StreamController<String> wordStreamController = StreamController<String>();
AudioPlayer audioPlayer = AudioPlayer();

Future<Map<String, dynamic>> convertTextToSpeechAndSave(String text) async {
  print('Starting to convert text to speech');
  print('$text');

  // Function to convert text to SSML with marks
  String textToSSMLWithMarks(String text) {
    final words = text.split(' ');
    final ssmlWords = words.asMap().entries.map((entry) {
      final markName = 'mark${entry.key}';
      return "<mark name='$markName'/>${entry.value}";
    }).join(' ');

    return "<speak>$ssmlWords</speak>";
  }

  String ssml = textToSSMLWithMarks(text);
  print('SSML markup: $ssml');

  // Define the API endpoint and headers
  String url = "https://texttospeech.googleapis.com/v1beta1/text:synthesize";
  Map<String, String> headers = {
    "Content-Type": "application/json",
    "X-Goog-Api-Key": "AIzaSyDOzl4unLKCAoDT1f5nlVfCmzXejDHWDnE",
  };

  // Define the body of the request
  Map<String, dynamic> body = {
    "audioConfig": {
      "audioEncoding": "MP3",
      "effectsProfileId": ["small-bluetooth-speaker-class-device"],
      "pitch": -8.2,
      "speakingRate": 0.8
    },
    "input": {"ssml": ssml},
    "voice": {"languageCode": "en-AU", "name": "en-AU-Standard-D"},
    "enableTimePointing": ["SSML_MARK"]
  };

  print('Making POST request to $url');
  // Make a POST request to the API
  http.Response response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: jsonEncode(body), // Encode the body to JSON
  );

// Handle the
  print('Response body: ${response.body}');
  Map<String, dynamic> jsonData =
      jsonDecode(response.body) as Map<String, dynamic>;
  print('Successfully received response');

  String audioContent = jsonData['audioContent'] as String;

  print('Content extracted successfully');

  List<int> audioBytes = base64Decode(audioContent);

  print('Base64 Decoded');

// Extract the timepoints from the response
  List<dynamic> timepoints = jsonData['timepoints'] as List<dynamic>;
  List<String> words = text.split(' ');

// Add the word to each timepoint
  for (int i = 0; i < timepoints.length; i++) {
    timepoints[i]['word'] = words[i];
  }

  print('Timepoints: $timepoints');

// Get the path of the directory where you want to save the file
  Directory docDir = await getApplicationDocumentsDirectory();
  String dirPath = '${docDir.path}\\speech_outputs';
  await Directory(dirPath)
      .create(recursive: true); // Ensure the directory exists

  /// Sanitize the filename
  String sanitizedText = sanitizeFilename(text);
  String audioFilePath = '$dirPath/$sanitizedText.mp3'.replaceAll('/', '\\');
  String ssmlFilePath = '$dirPath/$sanitizedText.ssml'.replaceAll('/', '\\');

  print('Audio file path set to: $audioFilePath');
  print('SSML file path set to: $ssmlFilePath');

  // Create a new file at the desired path for the audio
  File audioFile = File(audioFilePath);

  // Write the audio bytes to the file
  await audioFile.writeAsBytes(audioBytes);
  print('Audio file written successfully');

  // Create a new file at the desired path for the SSML
  File ssmlFile = File(ssmlFilePath);

  // Write the SSML markup and the timepoints to the file
  await ssmlFile
      .writeAsString('$ssml\n\nTimepoints: ${jsonEncode(timepoints)}');
  print('SSML file and timepoints written successfully');
  return {
    'timepoints': timepoints,
    'audioFilePath': audioFilePath,
  };
}

//Speak and Play the audio

Future<List<Map<String, dynamic>>> speakAndPlay(
  String text,
) async {
  print('Starting to speak and play');

  // Get the path of the directory where you're saving the file in the `speakMe` function
  Directory docDir = await getApplicationDocumentsDirectory();
  String dirPath = '${docDir.path}\\speech_outputs';

  // Sanitize the filename
  String sanitizedText = sanitizeFilename(text);
  String filePath = '$dirPath/$sanitizedText.mp3'.replaceAll('/', '\\');

  File audioFile = File(filePath);

  Map<String, dynamic> result;
  if (await audioFile.exists()) {
    print('File already exists, playing existing file');

    // Read the SSML content from the existing file
    String ssmlFilePath = '$dirPath/$sanitizedText.ssml'.replaceAll('/', '\\');
    File ssmlFile = File(ssmlFilePath);
    String ssmlContent = await ssmlFile.readAsString();

    print('SSML content: $ssmlContent'); // Log the SSML content

    // Extract the timepoints content from the SSML content
    List<String> splitContent = ssmlContent.split('Timepoints: ');
    if (splitContent.length < 2) {
      print('No timepoints found in the SSML content');
    }

    RegExp timepointsRegExp = RegExp(r'Timepoints: (\[.*\])');
    Match? timepointsMatch = timepointsRegExp.firstMatch(ssmlContent);
    String timepointsContent =
        timepointsMatch != null ? timepointsMatch.group(1)! : '';

    print('Timepoints content: $timepointsContent');

    // Extract the timepoints from the SSML content and the timepoints content
    List<Map<String, dynamic>> timepoints = timepointsContent.isNotEmpty
        ? List<Map<String, dynamic>>.from(
            jsonDecode(timepointsContent) as List<dynamic>)
        : [];

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
