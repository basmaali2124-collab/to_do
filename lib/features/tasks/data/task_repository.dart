import 'dart:convert';

import 'package:to_do_app/core/task_model.dart';
import 'package:to_do_app/features/tasks/data/database_helper.dart';

class TaskRepository {
  final DatabaseHelper _db;
  TaskRepository(this._db);

  Future<List<TaskModel>> getAll() async {
    final rows = await _db.readData('''
      SELECT * FROM Tasks
      ORDER BY
        endAt IS NULL,
        endAt ASC
    ''');
    return rows.map<TaskModel>((r) => TaskModel.fromMap(r)).toList();
  }
  Future<int> insert(TaskModel task) => _db.insertData('Tasks', task.toMap());

  Future<void> update(TaskModel task) async {
    final map = task.toMap()..remove('id');
    final setClause = map.keys.map((k) => '$k = ?').join(', ');

    await _db.updateData(
      'UPDATE Tasks SET $setClause WHERE id = ?',
      [...map.values, task.id],
    );
  }

  Future<void> updateStatus(int id, Status status) async {
    await _db.updateData(
      'UPDATE Tasks SET status = ? WHERE id = ?',
      [status.name, id],
    );
  }

  Future<void> updateSubtasks(
    int id,
    List<SubTask> subtasks,
    Status status,
  ) async {
    await _db.updateData(
      'UPDATE Tasks SET subtasks = ?, status = ? WHERE id = ?',
      [
        jsonEncode(subtasks.map((e) => e.toMap()).toList()),
        status.name,
        id,
      ],
    );
  }

  Future<void> delete(int id) async {
    await _db.deleteData('DELETE FROM Tasks WHERE id = ?', [id]);
  }
}