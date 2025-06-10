// stt_service.dart
import 'package:speech_to_text/speech_to_text.dart';

class STTService {
  static final SpeechToText _speech = SpeechToText();
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (!_isInitialized) {
      _isInitialized = await _speech.initialize();
    }
  }

  static Future<String> listen({int seconds = 5}) async {
    if (!_isInitialized) await init();
    if (!_isInitialized) return '';

    String result = '';
    await _speech.listen(
      onResult: (val) {
        result = val.recognizedWords;
      },
      localeId: 'en_US',
    );

    await Future.delayed(Duration(seconds: seconds));
    await _speech.stop();

    return result;
  }
}