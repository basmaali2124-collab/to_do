import 'dart:convert';
import 'package:intl/intl.dart';

enum Status { pending, completed }
enum TaskPriority { low, medium, high }
enum Category { work, personal, health, home, shopping, others }

final DateFormat _dbDateFormat = DateFormat('yyyy-MM-dd-HH:mm');

class TaskModel {
  int? id;
  String title;
  String? description;
  DateTime? startAt;
  DateTime? endAt;
  Status status;
  TaskPriority priority;
  Category category;
  List<SubTask> subtasks;

  TaskModel({
    this.id,
    required this.title,
    this.description,
    this.startAt,
    this.endAt,
    this.status = Status.pending,
    this.priority = TaskPriority.low,
    this.category = Category.others,
    this.subtasks = const [],
  });

  bool get isOverdue {
    if (status == Status.completed) return false;
    final due = endAt ?? startAt;
    return due != null && due.isBefore(DateTime.now());
  }
  factory TaskModel.fromMap(Map<String, dynamic> data) {
    List<SubTask> parsedSubtasks = [];
    if (data['subtasks'] != null && data['subtasks'].toString().isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(data['subtasks'] as String);
        parsedSubtasks = decoded
            .map((e) => SubTask.fromMap(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        parsedSubtasks = [];
      }
    }
    return TaskModel(
      id: data['id'] as int?,
      title: data['title'] as String,
      description: data['description'] as String?,
      startAt: data['startAt'] != null
          ? _dbDateFormat.parse(data['startAt'] as String)
          : null,
      endAt: data['endAt'] != null
          ? _dbDateFormat.parse(data['endAt'] as String)
          : null,
      status: (data['status'] as String?) == 'completed'
          ? Status.completed
          : Status.pending,
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == (data['priority'] as String? ?? 'low'),
        orElse: () => TaskPriority.low,
      ),
      category: Category.values.firstWhere(
        (e) => e.name == (data['category'] as String? ?? 'others'),
        orElse: () => Category.others,
      ),
      subtasks: parsedSubtasks,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'startAt': startAt != null ? _dbDateFormat.format(startAt!) : null,
      'endAt': endAt != null ? _dbDateFormat.format(endAt!) : null,
      'status': status.name,
      'priority': priority.name,
      'category': category.name,
      'subtasks': jsonEncode(subtasks.map((e) => e.toMap()).toList()),
    };
  }
}

class SubTask {
  String title;
  bool isCompleted;

  SubTask({
    required this.title,
    this.isCompleted = false,
  });

  factory SubTask.fromMap(Map<String, dynamic> map) {
    return SubTask(
      title: map['title'] as String,
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted,
    };
  }
}

extension SubTaskListStatus on List<SubTask> {
  Status resolveStatus(Status current) {
    if (isEmpty) return current;
    return every((s) => s.isCompleted) ? Status.completed : Status.pending;
  }
}