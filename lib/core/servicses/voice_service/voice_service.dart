import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService extends ChangeNotifier {
  VoiceService._();
  static final VoiceService instance = VoiceService._();

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _finalReceived = false;
  bool _stopRequested = false;
  String _lastWords = '';
  String? _localeId;
  String? _lastError;

  Future<void>? _initFuture;

  bool get speechEnabled => _speechEnabled;
  bool get isListening => _speechToText.isListening;
  bool get finalReceived => _finalReceived;
  String get lastWords => _lastWords;
  String? get lastError => _lastError;

  bool get usingFallbackLocale => _speechEnabled && _localeId == null;

  Future<void> init() {
    if (_speechEnabled) return Future.value();
    return _initFuture ??= _doInit().whenComplete(() => _initFuture = null);
  }

  Future<void> _doInit() async {
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
    _finalReceived = false;

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

    _localeId = null;
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    _lastWords = result.recognizedWords;
    if (result.finalResult) _finalReceived = true;
    notifyListeners();
  }
}