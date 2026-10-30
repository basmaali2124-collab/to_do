import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/core/app_colors.dart';
import 'package:to_do_app/core/extensions.dart';
import 'package:to_do_app/core/task_model.dart';
import 'package:to_do_app/core/widgets/app_pill.dart';
import 'package:to_do_app/core/widgets/tint_chip.dart';
import 'package:to_do_app/features/tasks/logic/task_cubit/task_cubit.dart';
import 'package:to_do_app/features/tasks/persentions/task_operations/task_details.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;

    final isDone = task.status == Status.completed;
    final due = task.endAt ?? task.startAt;
    final isOverdue = !isDone && due != null && due.isBefore(DateTime.now());
    final priorityColor =
        isDone ? c.taskCompleted : task.priority.colorOf(context);
    final hasDescription =
        task.description != null && task.description!.isNotEmpty;
    final hasDate = task.startAt != null || task.endAt != null;
    final doneSubtasks = task.subtasks.where((s) => s.isCompleted).length;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: c.border),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TaskDetails(task: task)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 14, 14, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                iconSize: 30,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                onPressed: () => context.read<TasksCubit>().toggleStatus(task),
                icon: Icon(
                  isDone ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: c.secondaryAccent,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: isDone
                                ? textTheme.titleLarge?.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: c.taskCompleted,
                                    color: c.taskCompleted,
                                  )
                                : textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AppPill(
                          compact: true,
                          icon: Icons.flag_rounded,
                          text: task.priority.label,
                          color: priorityColor,
                        ),
                      ],
                    ),
                    if (hasDescription) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall,
                      ),
                    ],
                    if (hasDate || task.subtasks.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (hasDate)
                            TintChip(
                              icon: Icons.schedule_rounded,
                              line1: task.dateLine,
                              line2: task.timeLine,
                            ),
                          if (task.subtasks.isNotEmpty)
                            TintChip(
                              icon: Icons.checklist_rounded,
                              line1: '$doneSubtasks/${task.subtasks.length}',
                            ),
                          if (isOverdue)
                            const TintChip(
                              icon: Icons.schedule_rounded,
                              line1: 'Overdue',
                              color: AppColors.destructive,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}