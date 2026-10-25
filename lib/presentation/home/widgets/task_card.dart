import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:to_do_app/core/app_colors.dart';
import 'package:to_do_app/core/app_typography.dart';
import 'package:to_do_app/data/task_model.dart';
import 'package:to_do_app/logic/task_cubit/task_cubit.dart';
import 'package:to_do_app/presentation/task_operations/delete_task.dart';
import 'package:to_do_app/presentation/task_operations/edit_task.dart';
import 'package:to_do_app/presentation/home/widgets/small_button.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;

  const TaskCard({super.key, required this.task});

  DateTime? get _dueDateTime {
    if (task.date == null || task.time == null) return null;
    return DateTime(
      task.date!.year,
      task.date!.month,
      task.date!.day,
      task.time!.hour,
      task.time!.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDone = task.status == Status.completed;
    final due = _dueDateTime;
    final isOverdue = !isDone && due != null && due.isBefore(DateTime.now());

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.only(top: 8, bottom: 12, left: 6),
        isThreeLine: true,
        leading: IconButton(
          style: IconButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          iconSize: 32,
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          onPressed: () => context.read<TasksCubit>().toggleStatus(task),
          icon: Icon(
            isDone ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: AppColors.secondaryAccentLight,
          ),
        ),
        title: Text(
          task.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: isDone
              ? AppTypography.lightTextTheme.titleLarge?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  decorationColor: AppColors.taskCompletedLight,
                  color: AppColors.taskCompletedLight,
                )
              : AppTypography.lightTextTheme.titleLarge,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null && task.description!.isNotEmpty)
              Text(
                task.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.lightTextTheme.bodySmall,
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (task.date != null)
                  _InfoChip(
                    icon: Icons.calendar_today_outlined,
                    text: DateFormat('dd MMM yyyy').format(task.date!),
                  ),
                if (task.time != null)
                  _InfoChip(
                    icon: Icons.access_time,
                    text: DateFormat('hh:mm a').format(task.time!),
                  ),
                _StatusBadge(isDone: isDone, isOverdue: isOverdue),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SmallButton(
              icon: Icons.edit_outlined,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditTask(taskModel: task),
                  ),
                );
              },
            ),
            SmallButton(
              icon: Icons.delete_outline_rounded,
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => const DeleteTask(),
                );
                if (confirmed == true && context.mounted) {
                  context.read<TasksCubit>().deleteTask(task.id!);
                }
              },
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.secondaryAccentLight),
        const SizedBox(width: 4),
        Text(text, style: AppTypography.lightTextTheme.bodySmall),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isDone;
  final bool isOverdue;
  const _StatusBadge({required this.isDone, required this.isOverdue});

  @override
  Widget build(BuildContext context) {
    final label = isDone
        ? 'Completed'
        : isOverdue
            ? 'Overdue'
            : 'Pending';

    final background = isOverdue
        ? AppColors.destructiveBg
        : AppColors.secondaryAccentLight.withValues(alpha: 0.3);

    final style = isOverdue
        ? AppTypography.lightTextTheme.bodySmall?.copyWith(
            color: AppColors.destructive,
            fontWeight: FontWeight.w600,
          )
        : AppTypography.lightTextTheme.bodySmall;

    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(label, style: style),
    );
  }
}