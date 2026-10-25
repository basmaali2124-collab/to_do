import 'package:to_do_app/data/task_model.dart';

enum TaskFilter { all, pending, completed }

abstract class TaskStates {}

class InitialState extends TaskStates {}

class LoadingState extends TaskStates {}

class SuccessState extends TaskStates {
  final List<TaskModel> tasks;
  final TaskFilter filter;
  final String? message;
  final bool isError;

  SuccessState(
    this.tasks, {
    this.filter = TaskFilter.all,
    this.message,
    this.isError = false,
  });

  int get total => tasks.length;
  int get completedCount =>
      tasks.where((t) => t.status == Status.completed).length;
  int get pendingCount => total - completedCount;

  List<TaskModel> get filteredTasks {
    switch (filter) {
      case TaskFilter.pending:
        return tasks.where((t) => t.status == Status.pending).toList();
      case TaskFilter.completed:
        return tasks.where((t) => t.status == Status.completed).toList();
      case TaskFilter.all:
        return tasks;
    }
  }
}

class FailedState extends TaskStates {
  final String message;
  FailedState(this.message);
}