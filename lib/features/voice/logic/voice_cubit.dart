import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/core/servicses/voice_service/voice_service.dart';
import 'package:to_do_app/features/tasks/logic/task_cubit/task_cubit.dart';
import 'package:to_do_app/features/voice/data/ai_exception.dart';
import 'package:to_do_app/features/voice/logic/voice_task_extractor.dart';

part 'voice_state.dart';

class VoiceTaskCubit extends Cubit<VoiceTaskState> {
  final TasksCubit _tasksCubit;
  final VoiceService _voice;
  final VoiceTaskExtractor _extractor;
  String _text = '';
  bool _wasListening = false;
  bool _processing = false;
  Timer? _finalTimer;

  VoiceTaskCubit({
    required TasksCubit tasksCubit,
    VoiceService? voice,
    VoiceTaskExtractor? extractor,
  })  : _tasksCubit = tasksCubit,
        _voice = voice ?? VoiceService.instance,
        _extractor = extractor ?? VoiceTaskExtractor(),
        super(const VoiceIdle()) {
    _voice.addListener(_onVoiceChanged);
  }

  void _emit(VoiceTaskState s) {
    if (!isClosed) emit(s);
  }

  void _fail(String message) {
    _emit(VoiceError(message));
    _emit(const VoiceIdle());
  }

  Future<void> toggle() async {
    if (_processing) return;
    if (!_voice.speechEnabled) await _voice.init();
    if (isClosed) return;
    if (!_voice.speechEnabled) {
      final err = _voice.lastError;
      _emit(VoiceError(
        err != null ? _speechErrorMessage(err) : 'Speech not available',
      ));
      return;
    }
    if (_voice.isListening) {
      await _voice.stopListening();
    } else {
      _text = '';
      await _voice.startListening();
    }
  }

  void _onVoiceChanged() {
    if (isClosed || _processing) return;

    final words = _voice.lastWords;
    if (words.isNotEmpty) _text = words;

    if (_voice.isListening) {
      _wasListening = true;
      _cancelTimer();
      if (state is! VoiceListening) _emit(const VoiceListening());
      return;
    }

    if (_wasListening) {
      if (_voice.finalReceived || _voice.lastError != null) {
        _startExtract();
      } else {
        _finalTimer ??= Timer(const Duration(milliseconds: 1500), () {
          _finalTimer = null;
          if (!isClosed && _wasListening) _startExtract();
        });
      }
      return;
    }

    if (state is! VoiceIdle) _emit(const VoiceIdle());
  }

  void _cancelTimer() {
    _finalTimer?.cancel();
    _finalTimer = null;
  }

  void _startExtract() {
    _cancelTimer();
    _wasListening = false;
    _extract();
  }

  String _speechErrorMessage(String code) {
    switch (code) {
      case 'error_no_match':
      case 'error_speech_timeout':
        return "Didn't hear anything, try again";
      case 'error_permission':
        return 'Microphone permission is required';
      case 'error_language_not_supported':
      case 'error_language_unavailable':
        return 'Arabic speech recognition is not available on this device';
      case 'error_network':
      case 'error_network_timeout':
        return 'Speech recognition needs an internet connection';
      default:
        return 'Speech recognition failed ($code)';
    }
  }

  Future<void> _extract() async {
    final raw = _text.trim();
    debugPrint('VOICE text: "$raw" (error: ${_voice.lastError})');

    if (raw.isEmpty) {
      final err = _voice.lastError;
      _fail(err != null
          ? _speechErrorMessage(err)
          : "Didn't hear anything, try again");
      return;
    }

    if (!_extractor.isConfigured) {
      debugPrint('AI skipped: OPENROUTER_API_KEY is not set in .env');
      _fail('AI is not configured');
      return;
    }

    _processing = true;
    _emit(const VoiceProcessing());

    ExtractionResult? result;
    String? failure;
    try {
      result = await _extractor.extract(raw);
    } catch (e, st) {
      debugPrint('AI error: $e\n$st');
      failure = e is AiException
          ? e.userMessage
          : 'Could not analyze the text, try again';
    } finally {
      _processing = false;
    }

    if (isClosed) return;

    if (result == null || result.total == 0) {
      _fail(failure ?? 'Could not analyze the text, try again');
      return;
    }
    if (result.valid.isEmpty) {
      _fail('That time has already passed, try again');
      return;
    }
    await _save(result);
  }

  Future<void> _save(ExtractionResult result) async {
    final skipped = result.skipped;

   final saved = await _tasksCubit.addTasks(
      result.valid,
      message: skipped > 0
          ? '${result.valid.length} added, $skipped skipped (time already passed)'
          : null,
    );

    _emit(saved ? VoiceDone(result.valid.length) : const VoiceIdle());
  }

  @override
  Future<void> close() {
    _cancelTimer();
    _voice.removeListener(_onVoiceChanged);
    if (_voice.isListening) _voice.stopListening();
    return super.close();
  }
}