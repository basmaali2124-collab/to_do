import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/features/home/logic/home_cubit/home_states.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  void changeFilter(TaskFilter filter) {
    if (filter == state.filter) return;
    emit(state.copyWith(filter: filter));
  }

  void changeSearch(String query) {
    if (query == state.query) return;
    emit(state.copyWith(query: query));
  }

  void clearSearch() => changeSearch('');


  EmptyContent emptyContent(int totalTasks) {
    switch (state.emptyType(totalTasks)) {
      case EmptyType.noTasks:
        return const EmptyContent(
          title: "Nothing on your list yet",
          subtitle:
              "Enjoy your free time or capture a new item to keep your mind clear.",
          showAddButton: true,
        );
      case EmptyType.noResults:
        return const EmptyContent(
          title: "No results found",
          subtitle: "Try a different keyword or change the filter.",
        );
      case EmptyType.noPending:
        return const EmptyContent(
          title: "No pending tasks",
          subtitle: "Everything is done. Nice work!",
        );
      case EmptyType.noCompleted:
        return const EmptyContent(
          title: "No completed tasks yet",
          subtitle: "Finish a task and it will show up here.",
        );
    }
  }
}