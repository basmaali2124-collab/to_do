import 'package:flutter/material.dart';
import 'package:to_do_app/core/app_colors.dart';
import 'package:to_do_app/core/task_model.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/field_label.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/section_card.dart';

class SubtaskSection extends StatelessWidget {
  final List<SubTask> subtasks;
  final TextEditingController controller;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const SubtaskSection({
    super.key,
    required this.subtasks,
    required this.controller,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return SectionCard(
      children: [
        FieldLabel(
          'Subtasks',
          suffix: '(Optional)',
          suffixColor: c.textSecondary,
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  hintText: 'Add a subtask...',
                ),
                onSubmitted: (_) => onAdd(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        if (subtasks.isNotEmpty) ...[
          const SizedBox(height: 12),
          for (int i = 0; i < subtasks.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.only(left: 12, right: 4),
                constraints: const BoxConstraints(minHeight: 44),
                decoration: BoxDecoration(
                  color: c.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.subdirectory_arrow_right_rounded,
                      size: 18,
                      color: c.secondaryAccent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        subtasks[i].title,
                        style: textTheme.bodyMedium,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      color: AppColors.destructive,
                      visualDensity: VisualDensity.compact,
                      onPressed: () => onRemove(i),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}