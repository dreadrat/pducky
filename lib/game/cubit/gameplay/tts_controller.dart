import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

//Converting the text input to audio and SSML markup with timestamps

StreamController<String> wordStreamController = StreamController<String>();

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

// Handle the response
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
  await ssmlFile.writeAsString('$ssml\n\nTimepoints: $timepoints');
  print('SSML file and timepoints written successfully');
  return {
    'timepoints': timepoints,
    'audioFilePath': audioFilePath,
  };
}

//Speak and Play the audio

Future<List<Map<String, dynamic>>> speakAndPlay(
    String text, AudioPlayer audioPlayer) async {
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

    // Extract the timepoints content from the SSML content
    String timepointsContent = ssmlContent.split('Timepoints: ')[1];

    // Extract the timepoints from the SSML content and the timepoints content
    List<Map<String, dynamic>> timepoints =
        extractTimepoints(ssmlContent, timepointsContent);

    result = {
      'audioFilePath': filePath,
      'timepoints': timepoints,
      // You might want to read the timepoints from the existing file here
    };
  } else {
    print('File does not exist, creating new file');
    result = await convertTextToSpeechAndSave(text);
  }

  print('Setting audio source to $filePath');
  await audioPlayer.setSource(DeviceFileSource(filePath));

  // Get the timepoints
  List<dynamic> timepoints = result['timepoints'] as List<dynamic>;
  print('Timepoints: $timepoints');
  timepoints.forEach((timepoint) {
    print('Timepoint: $timepoint');
  });

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
  RegExp markRegExp = RegExp(r"<mark name='(mark\d+)'\/>");
  Iterable<Match> matches = markRegExp.allMatches(ssmlContent);

  List<Map<String, dynamic>> timepoints = [];
  for (Match match in matches) {
    String markName = match.group(1)!;
    Map<String, dynamic>? timepoint =
        extractTimepoint(timepointsContent, markName);
    if (timepoint != null) {
      timepoints.add(timepoint);
    }
  }

  return timepoints;
}

Map<String, dynamic>? extractTimepoint(
    String timepointsContent, String markName) {
  RegExp timepointRegExp =
      RegExp(r"\{markName: $markName, timeSeconds: (\d+\.\d+)\}");
  Match? match = timepointRegExp.firstMatch(timepointsContent);
  if (match != null) {
    double timeSeconds = double.parse(match.group(1)!);
    return {
      'markName': markName,
      'timeSeconds': timeSeconds,
    };
  } else {
    return null;
  }
}
