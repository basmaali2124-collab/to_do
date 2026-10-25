import 'package:to_do_app/features/tasks/data/task_model.dart';

abstract class TaskStates {}

class InitialState extends TaskStates {}

class LoadingState extends TaskStates {}

class FailedState extends TaskStates {
  final String message;
  FailedState(this.message);
}

class SuccessState extends TaskStates {
  final List<TaskModel> tasks;
  final String? message;
  final bool isError;

  SuccessState(this.tasks, {this.message, this.isError = false});

  int get total => tasks.length;
  int get pendingCount =>
      tasks.where((t) => t.status == Status.pending).length;
  int get completedCount =>
      tasks.where((t) => t.status == Status.completed).length;
}