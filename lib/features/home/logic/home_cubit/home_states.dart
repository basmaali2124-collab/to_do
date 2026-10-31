import 'package:to_do_app/core/task_model.dart';
import 'package:to_do_app/features/home/logic/home_cubit/home_enums.dart';
export 'package:to_do_app/features/home/logic/home_cubit/home_enums.dart';

class HomeState {
  final StatusFilterType filter;
  final CategoryFilterType categoryFilter;
  final String query;
  final bool sortByPriority;

  const HomeState({
    this.filter = StatusFilterType.all,
    this.categoryFilter = CategoryFilterType.all,
    this.query = '',
    this.sortByPriority = false,
  });

  bool get isSearching => query.trim().isNotEmpty;

  EmptyType emptyType(int totalTasks) {
    if (totalTasks == 0) return EmptyType.noTasks;
    if (isSearching) return EmptyType.noResults;
    if (filter == StatusFilterType.pending) return EmptyType.noPending;
    if (filter == StatusFilterType.completed) return EmptyType.noCompleted;
    if (categoryFilter != CategoryFilterType.all) {
      return EmptyType.emptyCategory;
    }
    return EmptyType.noCompleted;
  }

  List<TaskModel> apply(List<TaskModel> tasks) {
    Iterable<TaskModel> result = tasks;

    switch (filter) {
      case StatusFilterType.pending:
        result = result.where((t) => t.status == Status.pending);
        break;
      case StatusFilterType.completed:
        result = result.where((t) => t.status == Status.completed);
        break;
      case StatusFilterType.all:
        break;
    }

    if (categoryFilter != CategoryFilterType.all) {
      result = result.where((t) => t.category.name == categoryFilter.name);
    }

    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where(
        (t) =>
            t.title.toLowerCase().contains(q) ||
            (t.description?.toLowerCase().contains(q) ?? false),
      );
    }

    final list = result.toList();

    if (sortByPriority) {
      list.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    }

    return list;
  }

  Map<Category, List<TaskModel>> groupByCategory(List<TaskModel> tasks) {
    final map = <Category, List<TaskModel>>{};
    for (final task in tasks) {
      map.putIfAbsent(task.category, () => []).add(task);
    }
    final ordered = <Category, List<TaskModel>>{};
    for (final cat in Category.values) {
      if (map.containsKey(cat)) ordered[cat] = map[cat]!;
    }
    return ordered;
  }

  HomeState copyWith({
    StatusFilterType? filter,
    CategoryFilterType? categoryFilter,
    String? query,
    bool? sortByPriority,
  }) =>
      HomeState(
        filter: filter ?? this.filter,
        categoryFilter: categoryFilter ?? this.categoryFilter,
        query: query ?? this.query,
        sortByPriority: sortByPriority ?? this.sortByPriority,
      );
}