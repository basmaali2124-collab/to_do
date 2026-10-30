import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:to_do_app/core/app_colors.dart';
import 'package:to_do_app/features/home/logic/home_cubit/home_cubit.dart';
import 'package:to_do_app/features/home/logic/home_cubit/home_states.dart';
import 'package:to_do_app/features/home/persention/widgets/category_filter.dart';
import 'package:to_do_app/features/home/persention/widgets/empty_state.dart';
import 'package:to_do_app/features/home/persention/widgets/error_state.dart';
import 'package:to_do_app/features/home/persention/widgets/grouped_tasks.dart';
import 'package:to_do_app/features/home/persention/widgets/home_header.dart';
import 'package:to_do_app/features/home/persention/widgets/search_sort_bar.dart';
import 'package:to_do_app/features/home/persention/widgets/status_filter.dart';
import 'package:to_do_app/features/tasks/logic/task_cubit/task_cubit.dart';
import 'package:to_do_app/features/tasks/logic/task_cubit/task_states.dart';
import 'package:to_do_app/features/tasks/persentions/task_operations/add_task.dart';
import 'package:to_do_app/features/voice/widgets/mic_button.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  Widget _buildEmpty(BuildContext context, HomeState homeState, int total) {
    final content = homeState.emptyType(total).content;

    return EmptyState(
      title: content.title,
      subtitle: content.subtitle,
      onAddPressed: content.showAddButton
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddTask()),
              );
            }
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TasksCubit, TaskStates>(
      listenWhen: (previous, current) =>
          current is SuccessState && current.message != null,
      listener: (context, state) {
        final success = state as SuccessState;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(success.message!),
              behavior: SnackBarBehavior.floating,
              backgroundColor: success.isError ? AppColors.destructive : null,
              duration: const Duration(seconds: 2),
            ),
          );
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: 60.h,
              left: 20.w,
              right: 20.w,
              bottom: 90.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeHeader(),
                const SizedBox(height: 12),
                BlocBuilder<TasksCubit, TaskStates>(
                  builder: (context, taskState) {
                    if (taskState is LoadingState ||
                        taskState is InitialState) {
                      return Padding(
                        padding: EdgeInsets.only(top: 80.h),
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (taskState is FailedState) {
                      return ErrorState(message: taskState.message);
                    }

                    final success = taskState as SuccessState;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        BlocBuilder<HomeCubit, HomeState>(
                          builder: (context, homeState) {
                            final homeCubit = context.read<HomeCubit>();
                            final filtered = homeState.apply(success.tasks);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SearchSortBar(
                                  homeState: homeState,
                                  homeCubit: homeCubit,
                                ),
                                const SizedBox(height: 14),
                                StatusFilter(
                                  success: success,
                                  filter: homeState.filter,
                                  homeCubit: homeCubit,
                                ),
                                const SizedBox(height: 10),
                                CategoryFilter(
                                  success: success,
                                  categoryFilter: homeState.categoryFilter,
                                  homeCubit: homeCubit,
                                ),
                                const SizedBox(height: 16),
                                if (filtered.isEmpty)
                                  _buildEmpty(context, homeState, success.total)
                                else
                                  GroupedTasks(
                                    homeState: homeState,
                                    tasks: filtered,
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: const VoiceMicButton(),
      ),
    );
  }
}