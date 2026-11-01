import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/core/servicses/notification_service.dart';
import 'package:to_do_app/core/task_model.dart';
import 'package:to_do_app/core/validation_helper.dart';
import 'package:to_do_app/features/tasks/data/database_helper.dart';
import 'package:to_do_app/features/tasks/data/task_repository.dart';
import 'package:to_do_app/features/tasks/logic/task_cubit/task_states.dart';

class TasksCubit extends Cubit<TaskStates> {
  final TaskRepository _repo;
  TasksCubit(DatabaseHelper db)
    : _repo = TaskRepository(db),
      super(InitialState());

  Future<void> loadTasks({bool showLoading = true, String? message}) async {
    if (showLoading) emit(LoadingState());
    try {
      final tasks = await _repo.getAll();
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
        status: subtasks.resolveStatus(original.status),
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

  Future<void> addTask(TaskModel task) => addTasks([task]);

  /// بترجّع true لو كل التاسكات اتحفظت، false لو حصل خطأ.
  /// [message] لو اتبعتت بتحل محل الرسالة الافتراضية.
  Future<bool> addTasks(List<TaskModel> tasks, {String? message}) async {
    try {
      for (final task in tasks) {
        task.id = await _repo.insert(task);
        await _safeNotify(() => NotificationService.instance.schedule(task));
      }
      await loadTasks(
        showLoading: false,
        message:
            message ??
            (tasks.length == 1 ? 'Task added' : '${tasks.length} tasks added'),
      );
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      await _repo.update(task);
      await _safeNotify(() => NotificationService.instance.schedule(task));
      await loadTasks(showLoading: false, message: 'Task updated');
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
      await _repo.updateStatus(task.id!, newStatus);

      task.status = newStatus;
      await _syncNotification(task);

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

    final newStatus = updated.resolveStatus(task.status);
    final statusChanged = newStatus != task.status;

    try {
      await _repo.updateSubtasks(task.id!, updated, newStatus);

      if (statusChanged) {
        task.status = newStatus;
        await _syncNotification(task);
      }

      await loadTasks(showLoading: false);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _repo.delete(id);
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

  /// لو التاسك خلصت بيلغي الإشعار، غير كده بيجدوله.
  Future<void> _syncNotification(TaskModel task) => _safeNotify(
    () => task.status == Status.completed
        ? NotificationService.instance.cancel(task.id!)
        : NotificationService.instance.schedule(task),
  );

  Future<void> _safeNotify(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {}
  }
}
