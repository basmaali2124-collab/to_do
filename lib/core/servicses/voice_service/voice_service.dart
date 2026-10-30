import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService extends ChangeNotifier {
  VoiceService._();
  static final VoiceService instance = VoiceService._();

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _initializing = false;
  String _lastWords = '';
  String? _localeId;
  String? _lastError;

  bool finalReceived = false;

  bool get speechEnabled => _speechEnabled;
  bool get isListening => _speechToText.isListening;
  String get lastWords => _lastWords;
  String? get lastError => _lastError;

  bool get usingFallbackLocale => _speechEnabled && _localeId == null;

  bool _stopRequested = false;

  Future<void> init() async {
    if (_speechEnabled || _initializing) return;
    _initializing = true;
    try {
      _speechEnabled = await _speechToText.initialize(
        onStatus: (_) => notifyListeners(),
        onError: (e) {
          debugPrint('Speech error: $e');

          if (e.errorMsg == 'error_client' &&
              (_stopRequested || _lastWords.isNotEmpty)) {
            notifyListeners();
            return;
          }

          _lastError = e.errorMsg;
          if (e.permanent) _speechEnabled = false;
          notifyListeners();
        },
      );
      if (_speechEnabled) await _pickLocale();
    } catch (e) {
      debugPrint('Speech init failed: $e');
      _speechEnabled = false;
    } finally {
      _initializing = false;
    }
    notifyListeners();
  }

  Future<void> startListening() async {
    if (!_speechEnabled) return;

    if (_speechToText.isListening) {
      await _speechToText.cancel();
      await Future.delayed(const Duration(milliseconds: 300));
    }

    _stopRequested = false;
    _lastWords = '';
    _lastError = null;
    finalReceived = false;

    await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: _localeId,
    );
    notifyListeners();
  }

  Future<void> stopListening() async {
    _stopRequested = true;
    await _speechToText.stop();
    notifyListeners();
  }

  Future<void> _pickLocale() async {
    final locales = await _speechToText.locales();
    String norm(String s) => s.replaceAll('-', '_').toLowerCase();

    for (final l in locales) {
      if (norm(l.localeId) == 'ar_eg') {
        _localeId = l.localeId;
        return;
      }
    }
    for (final l in locales) {
      if (norm(l.localeId).startsWith('ar')) {
        _localeId = l.localeId;
        return;
      }
    }

    _localeId = null;//'ar_EG';
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    _lastWords = result.recognizedWords;
    if (result.finalResult) finalReceived = true;
    notifyListeners();
  }
}