import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/core/servicses/notification_service.dart';
import 'package:to_do_app/core/validation_helper.dart';
import 'package:to_do_app/features/tasks/data/database_helper.dart';
import 'package:to_do_app/core/task_model.dart';
import 'package:to_do_app/features/tasks/logic/task_cubit/task_states.dart';

class TasksCubit extends Cubit<TaskStates> {
  final DatabaseHelper _db;
  TasksCubit(this._db) : super(InitialState());

  Future<void> loadTasks({bool showLoading = true, String? message}) async {
    if (showLoading) emit(LoadingState());
    try {
      final rows = await _db.readData('''
        SELECT * FROM Tasks
        ORDER BY
          endAt IS NULL,
          endAt ASC
      ''');
      final tasks = rows.map<TaskModel>((r) => TaskModel.fromMap(r)).toList();
      emit(SuccessState(tasks, message: message));
    } catch (e) {
      _handleError(e);
    }
  }

  DateTimeError submitTask({
  required String title,
  required String description,
  required DateTime startAt,
  required DateTime endAt,
  TaskPriority priority = TaskPriority.low,
  Category category = Category.others,
  List<SubTask> subtasks = const [],
}) {
  final error = DateTimeValidator.checkRange(startAt, endAt);
  if (error != DateTimeError.none) return error;

  addTask(
    TaskModel(
      title: title.trim(),
      description: description.trim().isEmpty ? null : description.trim(),
      startAt: startAt,
      endAt: endAt,
      priority: priority,
      category: category,
      subtasks: subtasks,
    ),
  );
  return DateTimeError.none;
}

DateTimeError submitUpdate({
  required TaskModel original,
  required String title,
  required String description,
  required DateTime startAt,
  required DateTime endAt,
  required bool dateTimeChanged,
  TaskPriority priority = TaskPriority.low,
  Category category = Category.others,
  List<SubTask> subtasks = const [],
}) {
  if (dateTimeChanged) {
    final error = DateTimeValidator.checkRange(startAt, endAt);
    if (error != DateTimeError.none) return error;
  }

  updateTask(
    TaskModel(
      id: original.id,
      status: original.status == Status.completed &&
              subtasks.any((s) => !s.isCompleted)
          ? Status.pending
          : original.status,
      priority: priority,
      category: category,
      subtasks: subtasks,
      title: title.trim(),
      description: description.trim().isEmpty ? null : description.trim(),
      startAt: startAt,
      endAt: endAt,
    ),
  );
  return DateTimeError.none;
}
  Future<void> addTask(TaskModel task) async {
    try {
      final id = await _db.insertData('Tasks', task.toMap());
      task.id = id;
      await _safeNotify(() => NotificationService.instance.schedule(task));
      await loadTasks(showLoading: false, message: 'Task added');
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      final map = task.toMap()..remove('id');
      final setClause = map.keys.map((k) => '$k = ?').join(', ');

      await _db.updateData(
        'UPDATE Tasks SET $setClause WHERE id = ?',
        [...map.values, task.id],
      );

      await _safeNotify(() => NotificationService.instance.schedule(task));
      await loadTasks(showLoading: false, message: 'Task updated');
    } catch (e) {
      _handleError(e);
    }
  }
   
   Future<void> addTasks(List<TaskModel> tasks) async {
  try {
    for (final task in tasks) {
      final id = await _db.insertData('Tasks', task.toMap());
      task.id = id;
      await _safeNotify(() => NotificationService.instance.schedule(task));
    }
    await loadTasks(
      showLoading: false,
      message: tasks.length == 1 ? 'Task added' : '${tasks.length} tasks added',
    );
  } catch (e) {
    _handleError(e);
  }
}
  Future<void> toggleStatus(TaskModel task) async {
    final isCompleting = task.status == Status.pending;

   if (isCompleting && task.subtasks.any((s) => !s.isCompleted)) {
      final current = state;
      if (current is SuccessState) {
        emit(
          SuccessState(
            current.tasks,
            message: 'Finish all subtasks first',
            isError: true,
          ),
        );
        emit(SuccessState(current.tasks));
      }
      return;
    }
    final newStatus = isCompleting ? Status.completed : Status.pending;
    try {
      await _db.updateData(
        'UPDATE Tasks SET status = ? WHERE id = ?',
        [newStatus.name, task.id],
      );

      task.status = newStatus;
      if (isCompleting) {
        await _safeNotify(() => NotificationService.instance.cancel(task.id!));
      } else {
        await _safeNotify(() => NotificationService.instance.schedule(task));
      }

      await loadTasks(showLoading: false);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> toggleSubtask(TaskModel task, int index) async {
    if (index < 0 || index >= task.subtasks.length) return;

    final updated = task.subtasks
        .map((s) => SubTask(title: s.title, isCompleted: s.isCompleted))
        .toList();
    updated[index].isCompleted = !updated[index].isCompleted;

    final newStatus =
        updated.every((s) => s.isCompleted) ? Status.completed : Status.pending;
    final statusChanged = newStatus != task.status;

    try {
      await _db.updateData(
        'UPDATE Tasks SET subtasks = ?, status = ? WHERE id = ?',
        [
          jsonEncode(updated.map((e) => e.toMap()).toList()),
          newStatus.name,
          task.id,
        ],
      );

      if (statusChanged) {
        task.status = newStatus;
        if (newStatus == Status.completed) {
          await _safeNotify(() => NotificationService.instance.cancel(task.id!));
        } else {
          await _safeNotify(() => NotificationService.instance.schedule(task));
        }
      }

      await loadTasks(showLoading: false);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _db.deleteData('DELETE FROM Tasks WHERE id = ?', [id]);
      await _safeNotify(() => NotificationService.instance.cancel(id));
      await loadTasks(showLoading: false, message: 'Task deleted');
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleError(Object e) {
    final current = state;
    if (current is SuccessState) {
      emit(
        SuccessState(
          current.tasks,
          message: 'Something went wrong, please try again',
          isError: true,
        ),
      );
    } else {
      emit(FailedState(e.toString()));
    }
  }

  Future<void> _safeNotify(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {}
  }
}