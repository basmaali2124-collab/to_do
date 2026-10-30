import 'package:flutter/material.dart';
import 'package:to_do_app/core/app_colors.dart';
import 'package:to_do_app/core/task_model.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/section_card.dart';

class SubtasksChecklistCard extends StatelessWidget {
  final List<SubTask> subtasks;
  final ValueChanged<int> onToggle;

  const SubtasksChecklistCard({
    super.key,
    required this.subtasks,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;

    final total = subtasks.length;
    final done = subtasks.where((s) => s.isCompleted).length;

    return SectionCard(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Subtasks',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (total > 0)
              Text(
                '$done/$total',
                style: textTheme.bodySmall?.copyWith(
                  color: c.secondaryAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        if (total == 0) ...[
          const SizedBox(height: 8),
          Text(
            'No subtasks for this task.',
            style: textTheme.bodySmall?.copyWith(color: c.textSecondary),
          ),
        ] else ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: done / total,
              minHeight: 6,
              color: c.secondaryAccent,
              backgroundColor: c.secondaryAccent.withValues(alpha: 0.15),
            ),
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < total; i++)
            _SubtaskRow(subtask: subtasks[i], onTap: () => onToggle(i)),
        ],
      ],
    );
  }
}

class _SubtaskRow extends StatelessWidget {
  final SubTask subtask;
  final VoidCallback onTap;

  const _SubtaskRow({required this.subtask, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final done = subtask.isCompleted;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Checkbox(
              value: done,
              onChanged: (_) => onTap(),
              activeColor: c.secondaryAccent,
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                subtask.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      decoration: done ? TextDecoration.lineThrough : null,
                      decorationColor: c.textSecondary,
                      color: done ? c.textSecondary : null,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}