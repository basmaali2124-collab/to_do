import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService extends ChangeNotifier {
VoiceService._();
static final VoiceService istance = VoiceService._();
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  bool get speechEnabled => _speechEnabled;
  bool get isListening => _speechToText.isListening;
  String get lastWords => _lastWords;

  Future<void> init() async {
    _speechEnabled = await _speechToText.initialize();
    notifyListeners();
  }

  Future<void> startListening() async {
    await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: 'ar_EG',
    );
    notifyListeners();
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
    notifyListeners();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    _lastWords = result.recognizedWords;
    notifyListeners();
  }
}