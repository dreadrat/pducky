/// TTS configuration.
///
/// Provide secrets locally at build/run time, not in git.
///
/// Recommended:
/// - create a gitignored file `secrets/tts.secrets.json` containing:
///   {"GOOGLE_TTS_API_KEY":"..."}
/// - run flutter with:
///   flutter run -d chrome --dart-define-from-file=secrets/tts.secrets.json
library;

/// Google Cloud Text-to-Speech API key.
///
/// Inject via `--dart-define` or `--dart-define-from-file`.
const googleTtsApiKey = String.fromEnvironment('GOOGLE_TTS_API_KEY');

bool get hasGoogleTtsApiKey => googleTtsApiKey.trim().isNotEmpty;
