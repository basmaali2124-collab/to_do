import 'package:intl/intl.dart';

enum Status { pending, completed }

class TaskModel {
  int? id;
  String title;
  String? description;
  DateTime? date;
  DateTime? time;
  Status status;

  TaskModel({
    this.id,
    required this.title,
    this.status = Status.pending,
    this.description,
    this.date,
    this.time,
  });

  factory TaskModel.fromMap(Map<String, dynamic> data) {
    DateTime? parsedTime;
    if (data['time'] != null) {
      final parts = (data['time'] as String).split(':');
      parsedTime = DateTime(0, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
    }

    return TaskModel(
      id: data['id'] as int?,
      title: data['title'] as String,
      description: data['description'] as String?,
      date: data['date'] != null ? DateTime.parse(data['date']) : null,
      time: parsedTime,
      status: data['status'] == 'completed' ? Status.completed : Status.pending,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'date': date != null ? DateFormat('yyyy-MM-dd').format(date!) : null,
      'time': time != null ? DateFormat('HH:mm').format(time!) : null,
      'status': status.name,
    };
  }
}