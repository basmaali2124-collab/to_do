import 'package:to_do_app/core/task_model.dart';

class ParsedTask {
  static const defaultDuration = Duration(hours: 1);

  final String title;
  final String? description;
  final DateTime dateTime;
  final DateTime? endDateTime;
  final TaskPriority priority;
  final Category category;
  final List<SubTask> subtasks;

  const ParsedTask({
    required this.title,
    this.description,
    required this.dateTime,
    this.endDateTime,
    this.priority = TaskPriority.low,
    this.category = Category.others,
    this.subtasks = const [],
  });

  DateTime get endOrDefault => endDateTime ?? dateTime.add(defaultDuration);
}