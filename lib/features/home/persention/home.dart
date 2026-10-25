import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:to_do_app/core/app_colors.dart';
import 'package:to_do_app/core/task_model.dart';
import 'package:to_do_app/features/home/logic/home_cubit/home_cubit.dart';
import 'package:to_do_app/features/home/logic/home_cubit/home_states.dart';
import 'package:to_do_app/features/tasks/logic/task_cubit/task_cubit.dart';
import 'package:to_do_app/features/tasks/logic/task_cubit/task_states.dart';
import 'package:to_do_app/features/tasks/persentions/task_operations/add_task.dart';
import 'package:to_do_app/features/home/persention/widgets/empty_state.dart';
import 'package:to_do_app/features/home/persention/widgets/home_header.dart';
import 'package:to_do_app/features/home/persention/widgets/progress_card.dart';
import 'package:to_do_app/features/home/persention/widgets/status_button.dart';
import 'package:to_do_app/features/home/persention/widgets/task_card.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddTask(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTask()));
  }

  Widget _buildEmpty(BuildContext context, SuccessState state) {
    final content = context.read<HomeCubit>().emptyContent(state.total);

    return EmptyState(
      title: content.title,
      subtitle: content.subtitle,
      onAddPressed: content.showAddButton ? () => _openAddTask(context) : null,
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.destructive,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.read<TasksCubit>().loadTasks(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  int _columnsFor(double width) {
    if (width >= 900) return 3;
    if (width >= 560) return 2;
    return 1;
  }

  Widget _buildTasks(List<TaskModel> tasks) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final width = constraints.maxWidth;
        final columns = _columnsFor(width);

        if (columns == 1) {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tasks.length,
            separatorBuilder: (_, _) => const SizedBox(height: spacing),
            itemBuilder: (context, i) {
              final task = tasks[i];
              return TaskCard(key: ValueKey(task.id), task: task);
            },
          );
        }

        final itemWidth = (width - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final task in tasks)
              SizedBox(
                width: itemWidth,
                child: TaskCard(key: ValueKey(task.id), task: task),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

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
                      return _buildError(context, taskState.message);
                    }

                    final success = taskState as SuccessState;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProgressCard(
                          completed: success.completedCount,
                          total: success.total,
                          percent: success.percent,
                        ),
                        const SizedBox(height: 12),
                        BlocBuilder<HomeCubit, HomeState>(
                          builder: (context, homeState) {
                            final homeCubit = context.read<HomeCubit>();
                            final filter = homeState.filter;
                            final filtered = homeState.apply(success.tasks);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: _searchController,
                                  onChanged: homeCubit.changeSearch,
                                  decoration: InputDecoration(
                                    hintText: 'Search tasks',
                                    prefixIcon: const Icon(
                                      Icons.search_rounded,
                                    ),
                                    suffixIcon: homeState.isSearching
                                        ? IconButton(
                                            icon: const Icon(
                                              Icons.close_rounded,
                                            ),
                                            onPressed: () {
                                              _searchController.clear();
                                              homeCubit.clearSearch();
                                            },
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  height: 50,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      StatusButton(
                                        name: 'All',
                                        num: success.total,
                                        isSelected: filter == TaskFilter.all,
                                        onPressed: () => homeCubit.changeFilter(
                                          TaskFilter.all,
                                        ),
                                      ),
                                      StatusButton(
                                        name: 'Pending',
                                        num: success.pendingCount,
                                        isSelected:
                                            filter == TaskFilter.pending,
                                        onPressed: () => homeCubit.changeFilter(
                                          TaskFilter.pending,
                                        ),
                                      ),
                                      StatusButton(
                                        name: 'Completed',
                                        num: success.completedCount,
                                        isSelected:
                                            filter == TaskFilter.completed,
                                        onPressed: () => homeCubit.changeFilter(
                                          TaskFilter.completed,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                if (filtered.isEmpty)
                                  _buildEmpty(context, success)
                                else
                                  _buildTasks(filtered),
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
        floatingActionButton: SizedBox(
          width: 60,
          height: 60,
          child: FloatingActionButton(
            onPressed: () => _openAddTask(context),
            backgroundColor: c.textMain,
            splashColor: c.surface,
            tooltip: 'Add task',
            shape: const CircleBorder(),
            child: Icon(Icons.add, size: 34, color: c.surface),
          ),
        ),
      ),
    );
  }
}
