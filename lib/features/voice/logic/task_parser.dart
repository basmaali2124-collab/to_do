import 'dart:convert';

import 'package:to_do_app/core/task_model.dart';
import 'package:to_do_app/features/voice/logic/parsed_task.dart';
abstract class TaskParser {
  static DateTime defaultDue() {
    final d = DateTime.now().add(const Duration(hours: 1));
    return DateTime(d.year, d.month, d.day, d.hour, d.minute);
  }

  static List<ParsedTask> parse(String reply, {required String fallbackTitle}) {
    final start = reply.indexOf('{');
    final end = reply.lastIndexOf('}');
    if (start == -1 || end <= start) {
      throw FormatException('No JSON object in reply: $reply');
    }
    final json =
        jsonDecode(reply.substring(start, end + 1)) as Map<String, dynamic>;

    final rawList = json['tasks'];
    final items = rawList is List
        ? rawList.whereType<Map<String, dynamic>>().toList()
        : [json];

    return items
        .map(
          (item) => _parseOne(
            item,
            fallbackTitle: items.length == 1 ? fallbackTitle : null,
          ),
        )
        .whereType<ParsedTask>()
        .toList();
  }

  static ParsedTask? _parseOne(
    Map<String, dynamic> json, {
    String? fallbackTitle,
  }) {
    final title = _clean(json['title']) ?? fallbackTitle;
    if (title == null) return null;

    final date = _date(json['date']);
    final time = _time(json['time']);

    final now = DateTime.now();
    final fallback = defaultDue();
    final today = DateTime(now.year, now.month, now.day);

    var day = date ?? today;
    for (var i = 0; date != null && day.isBefore(today) && i < 2; i++) {
      final next = DateTime(day.year + 1, day.month, day.day);
      if (next.month != day.month) break;
      day = next;
    }

    final hour = time?.hour ?? (date != null ? 9 : fallback.hour);
    final minute = time?.minute ?? (date != null ? 0 : fallback.minute);
    var result = DateTime(day.year, day.month, day.day, hour, minute);
    if (date == null && result.isBefore(now)) {
      result = result.add(const Duration(days: 1));
    }

    return ParsedTask(
      title: title,
      description: _cleanDescription(json['description'], title),
      dateTime: result,
      subtasks: _parseSubtasks(json['subtasks'], title: title),
      endDateTime: _parseEnd(json, start: result),
      priority: _priorityFrom(json['priority']),
      category: _enumFrom(Category.values, json['category'], Category.others),
    );
  }

  static String? _cleanDescription(Object? raw, String title) {
    final d = _clean(raw);
    if (d == null) return null;
    return d.toLowerCase() == title.toLowerCase() ? null : d;
  }

  static List<SubTask> _parseSubtasks(Object? raw, {required String title}) {
    if (raw is! List) return const [];
    final seen = <String>{};
    final result = <SubTask>[];
    for (final item in raw) {
      final text = _clean(item);
      if (text == null || !seen.add(text.toLowerCase())) continue;
      result.add(SubTask(title: text));
      if (result.length == 8) break;
    }
    if (result.length == 1 &&
        result.first.title.toLowerCase() == title.toLowerCase()) {
      return const [];
    }
    return result;
  }

  static DateTime? _parseEnd(
    Map<String, dynamic> json, {
    required DateTime start,
  }) {
    final endDate = _date(json['end_date']);
    final endTime = _time(json['end_time']);
    if (endDate == null && endTime == null) return null;

    final day = endDate ?? DateTime(start.year, start.month, start.day);
    var end = DateTime(
      day.year,
      day.month,
      day.day,
      endTime?.hour ?? start.hour,
      endTime?.minute ?? start.minute,
    );
 if (endDate == null && end.isBefore(start)) {
      end = end.add(const Duration(days: 1));
    }
    return end.isAfter(start) ? end : null;
  }

  static T _enumFrom<T extends Enum>(List<T> values, Object? raw, T fallback) {
    final s = _clean(raw)?.toLowerCase();
    for (final v in values) {
      if (v.name == s) return v;
    }
    return fallback;
  }

  static TaskPriority _priorityFrom(Object? raw) {
    final s = _clean(raw)?.toLowerCase();
    switch (s) {
      case 'high':
      case 'عالية':
      case 'عالي':
      case 'مهم':
      case 'عاجل':
        return TaskPriority.high;
      case 'medium':
      case 'متوسطة':
      case 'متوسط':
        return TaskPriority.medium;
      default:
        return TaskPriority.low;
    }
  }

  static String? _clean(Object? v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return null;
    return s;
  }

  static DateTime? _date(Object? v) {
    final s = _clean(v);
    if (s == null) return null;
    final m = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})').firstMatch(s);
    if (m == null) return null;
    final y = int.parse(m[1]!);
    final mo = int.parse(m[2]!);
    final d = int.parse(m[3]!);
    if (mo < 1 || mo > 12 || d < 1 || d > 31) return null;
    final dt = DateTime(y, mo, d);
    return dt.month == mo ? dt : null;
  }
 static ({int hour, int minute})? _time(Object? v) {
    final s = _clean(v);
    if (s == null) return null;
    final m = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(s);
    if (m == null) return null;
    final h = int.parse(m[1]!);
    final mi = int.parse(m[2]!);
    if (h > 23 || mi > 59) return null;
    return (hour: h, minute: mi);
  }
}