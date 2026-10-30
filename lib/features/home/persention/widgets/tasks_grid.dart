import 'package:flutter/material.dart';
import 'package:to_do_app/core/task_model.dart';
import 'package:to_do_app/features/home/persention/widgets/task_card.dart';

class TasksGrid extends StatelessWidget {
  final List<TaskModel> tasks;

  const TasksGrid({super.key, required this.tasks});

  static int _columnsFor(double width) {
    if (width >= 900) return 3;
    if (width >= 560) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
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
            separatorBuilder: (_, __) => const SizedBox(height: spacing),
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
}