import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/core/app_colors.dart';
import 'package:to_do_app/logic/task_cubit/task_cubit.dart';
import 'package:to_do_app/logic/task_cubit/task_states.dart';
import 'package:to_do_app/presentation/task_operations/add_task.dart';
import 'package:to_do_app/presentation/home/widgets/empty_state.dart';
import 'package:to_do_app/presentation/home/widgets/home_header.dart';
import 'package:to_do_app/presentation/home/widgets/progress_card.dart';
import 'package:to_do_app/presentation/home/widgets/status_button.dart';
import 'package:to_do_app/presentation/home/widgets/task_card.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  void _openAddTask(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTask()),
    );
  }

  Widget _buildEmpty(BuildContext context, SuccessState state) {
    if (state.total == 0) {
      return EmptyState(
        title: "Nothing on your list yet",
        subtitle:
            "Enjoy your free time or capture a new item to keep your mind clear.",
        onAddPressed: () => _openAddTask(context),
      );
    }
    if (state.filter == TaskFilter.pending) {
      return const EmptyState(
        title: "No pending tasks",
        subtitle: "Everything is done. Nice work!",
      );
    }
    return const EmptyState(
      title: "No completed tasks yet",
      subtitle: "Finish a task and it will show up here.",
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
            padding: const EdgeInsets.only(
              top: 60,
              left: 20,
              right: 20,
              bottom: 90,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeHeader(),
                const SizedBox(height: 12),
                BlocBuilder<TasksCubit, TaskStates>(
                  builder: (context, state) {
                    if (state is LoadingState || state is InitialState) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 80),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (state is FailedState) {
                      return _buildError(context, state.message);
                    }

                    final success = state as SuccessState;
                    final cubit = context.read<TasksCubit>();
                    final filtered = success.filteredTasks;
                    final percent = success.total == 0
                        ? 0.0
                        : success.completedCount / success.total;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProgressCard(
                          completed: success.completedCount,
                          total: success.total,
                          percent: percent,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 50,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              StatusButton(
                                name: 'All',
                                num: success.total,
                                isSelected: success.filter == TaskFilter.all,
                                onPressed: () =>
                                    cubit.changeFilter(TaskFilter.all),
                              ),
                              StatusButton(
                                name: 'Pending',
                                num: success.pendingCount,
                                isSelected:
                                    success.filter == TaskFilter.pending,
                                onPressed: () =>
                                    cubit.changeFilter(TaskFilter.pending),
                              ),
                              StatusButton(
                                name: 'Completed',
                                num: success.completedCount,
                                isSelected:
                                    success.filter == TaskFilter.completed,
                                onPressed: () =>
                                    cubit.changeFilter(TaskFilter.completed),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (filtered.isEmpty)
                          _buildEmpty(context, success)
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, i) {
                              final task = filtered[i];
                              return TaskCard(
                                key: ValueKey(task.id),
                                task: task,
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
            backgroundColor: AppColors.textMainLight,
            splashColor: AppColors.surfaceDark,
            tooltip: 'Add task',
            shape: const CircleBorder(),
            child: const Icon(
              Icons.add,
              size: 34,
              color: AppColors.surfaceLight,
            ),
          ),
        ),
      ),
    );
  }
}