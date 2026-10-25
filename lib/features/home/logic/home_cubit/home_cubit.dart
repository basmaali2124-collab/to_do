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
}