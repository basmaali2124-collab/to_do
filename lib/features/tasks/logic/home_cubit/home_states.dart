import 'package:to_do_app/features/tasks/data/task_model.dart';

enum TaskFilter { all, pending, completed }

class HomeState {
  final TaskFilter filter;
  final String query;

  const HomeState({this.filter = TaskFilter.all, this.query = ''});

  bool get isSearching => query.trim().isNotEmpty;

  /// بتطبق الفلتر ثم البحث، وبتحافظ على الترتيب
  List<TaskModel> apply(List<TaskModel> tasks) {
    Iterable<TaskModel> result = tasks;

    switch (filter) {
      case TaskFilter.pending:
        result = result.where((t) => t.status == Status.pending);
        break;
      case TaskFilter.completed:
        result = result.where((t) => t.status == Status.completed);
        break;
      case TaskFilter.all:
        break;
    }

    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where(
        (t) =>
            t.title.toLowerCase().contains(q) ||
            (t.description?.toLowerCase().contains(q) ?? false),
      );
    }

    return result.toList();
  }

  HomeState copyWith({TaskFilter? filter, String? query}) => HomeState(
        filter: filter ?? this.filter,
        query: query ?? this.query,
      );
}