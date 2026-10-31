import 'package:flutter/foundation.dart' show debugPrint;
import 'package:to_do_app/core/task_model.dart';
import 'package:to_do_app/core/validation_helper.dart';
import 'package:to_do_app/features/voice/data/ai_service.dart';
import 'package:to_do_app/features/voice/logic/ai_prompt.dart';
import 'package:to_do_app/features/voice/logic/task_parser.dart';

class ExtractionResult {
  final int total;
 final List<TaskModel> valid;

  const ExtractionResult({required this.total, required this.valid});

  int get skipped => total - valid.length;
}

class VoiceTaskExtractor {
  final AiService _ai;

  VoiceTaskExtractor({AiService? ai}) : _ai = ai ?? AiService.instance;

  bool get isConfigured => _ai.isConfigured;

  Future<ExtractionResult> extract(String text) async {
    final reply = await _ai.chatJson(text, system: AiPrompt.forText(text));
    debugPrint('AI reply: $reply');

    final tasks = TaskParser.parse(reply, fallbackTitle: text);
    final valid = tasks
        .where(
          (t) =>
              DateTimeValidator.checkRange(t.startAt!, t.endAt!) ==
              DateTimeError.none,
        )
        .toList();

    return ExtractionResult(total: tasks.length, valid: valid);
  }
}