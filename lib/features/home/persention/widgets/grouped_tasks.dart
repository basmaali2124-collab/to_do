import 'package:flutter/material.dart';
import 'package:to_do_app/core/extensions.dart';
import 'package:to_do_app/core/task_model.dart';
import 'package:to_do_app/features/home/logic/home_cubit/home_states.dart';
import 'package:to_do_app/features/home/persention/widgets/tasks_grid.dart';

class GroupedTasks extends StatelessWidget {
  final HomeState homeState;
  final List<TaskModel> tasks;

  const GroupedTasks({
    super.key,
    required this.homeState,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    if (homeState.categoryFilter != CategoryFilterType.all) {
      return TasksGrid(tasks: tasks);
    }

    final grouped = homeState.groupByCategory(tasks);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in grouped.entries) ...[
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              entry.key.label,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          TasksGrid(tasks: entry.value),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}