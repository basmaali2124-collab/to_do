import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/core/servicses/notification_service.dart';
import 'package:to_do_app/data/database_helper.dart';
import 'package:to_do_app/data/task_model.dart';
import 'package:to_do_app/logic/task_cubit/task_states.dart';

class TasksCubit extends Cubit<TaskStates> {
  final DatabaseHelper _db;
  TasksCubit(this._db) : super(InitialState());

  TaskFilter _filter = TaskFilter.all;

  void changeFilter(TaskFilter filter) {
    _filter = filter;
    final current = state;
    if (current is SuccessState) {
      emit(SuccessState(current.tasks, filter: _filter));
    }
  }

  Future<void> loadTasks({bool showLoading = true, String? message}) async {
    if (showLoading) emit(LoadingState());
    try {
      final rows = await _db.readData('SELECT * FROM Tasks');
      final tasks = rows.map<TaskModel>((r) => TaskModel.fromMap(r)).toList();
      emit(SuccessState(tasks, filter: _filter, message: message));
    } catch (e) {
      _handleError(e);
    }
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

  Future<void> toggleStatus(TaskModel task) async {
    final isCompleting = task.status == Status.pending;
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
        // رجعت Pending: يجدول من جديد لو وقتها لسه في المستقبل
        await _safeNotify(() => NotificationService.instance.schedule(task));
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
          filter: _filter,
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