import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:to_do_app/features/voice/data/ai_exception.dart';
export 'package:to_do_app/features/voice/data/ai_exception.dart';

class AiService {
  static String get _apiKey => (dotenv.env['OPENROUTER_API_KEY'] ?? '').trim();
  static String get _model {
    final m = (dotenv.env['OPENROUTER_MODEL'] ?? '').trim();
    return m.isNotEmpty ? m : 'google/gemma-4-31b-it';
  }

  static final AiService instance = AiService._();

  final Dio _dio;

  AiService._()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://openrouter.ai/api/v1',
            connectTimeout: const Duration(seconds: 10),
            sendTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 30),
            headers: {
              'Content-Type': 'application/json',
              'HTTP-Referer': 'https://todo-app.local',
              'X-Title': 'To Do App',
            },
          ),
        );

  bool get isConfigured => _apiKey.isNotEmpty;
Future<String> chatJson(String prompt, {String? system}) async {
    if (!isConfigured) {
      throw AiException(
          AiErrorKind.notConfigured, 'OPENROUTER_API_KEY is not set.');
    }
    try {
      final response = await _dio.post(
        '/chat/completions',
        options: Options(headers: {'Authorization': 'Bearer $_apiKey'}),
        data: {
          'model': _model,
          'temperature': 0,
          'response_format': {'type': 'json_object'},
          'messages': [
            if (system != null) {'role': 'system', 'content': system},
            {'role': 'user', 'content': prompt},
          ],
        },
      );

      final Object? data = response.data;
      if (data is Map<dynamic, dynamic>) {
        final Object? err = data['error'];
        if (err != null) {
          throw AiException(AiErrorKind.other, 'OpenRouter error: $err');
        }
      }

      String? content;
      if (data is Map<dynamic, dynamic>) {
        final Object? choices = data['choices'];
        if (choices is List<dynamic> && choices.isNotEmpty) {
          final Object? first = choices.first;
          if (first is Map<dynamic, dynamic>) {
            final Object? message = first['message'];
            if (message is Map<dynamic, dynamic>) {
              final Object? c = message['content'];
              if (c is String) content = c;
            }
          }
        }
      }
      if (content == null || content.trim().isEmpty) {
        throw AiException(AiErrorKind.badReply, 'Empty AI reply: $data');
      }
      return content.trim();
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final details = 'OpenRouter ${code ?? e.type.name}: '
          '${e.response?.data ?? e.message}';
      if (code == 401 || code == 403) {
        throw AiException(AiErrorKind.unauthorized, details);
      }
      if (code == 402) throw AiException(AiErrorKind.noCredits, details);
      if (code == 429) throw AiException(AiErrorKind.rateLimited, details);
      if (code == null &&
          (e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.sendTimeout)) {
        throw AiException(AiErrorKind.offline, details);
      }
      throw AiException(AiErrorKind.other, details);
    }
  }
}