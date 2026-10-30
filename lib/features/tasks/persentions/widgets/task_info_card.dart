import 'package:flutter/material.dart';
import 'package:to_do_app/core/app_colors.dart';
import 'package:to_do_app/core/extensions.dart';
import 'package:to_do_app/core/task_model.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/field_label.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/section_card.dart';

class TaskInfoCard extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TaskPriority priority;
  final Category category;
  final ValueChanged<TaskPriority> onPriorityChanged;
  final ValueChanged<Category> onCategoryChanged;

  const TaskInfoCard({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.priority,
    required this.category,
    required this.onPriorityChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return SectionCard(
      children: [
        const FieldLabel(
          'Task Title',
          suffix: '*',
          suffixColor: AppColors.destructive,
        ),
        TextFormField(
          controller: titleController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            hintText: 'e.g. Morning meditation',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a task title';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        FieldLabel(
          'Description',
          suffix: '(Optional)',
          suffixColor: c.textSecondary,
        ),
        TextField(
          controller: descriptionController,
          minLines: 2,
          maxLines: 4,
          textInputAction: TextInputAction.newline,
          decoration: const InputDecoration(
            hintText: 'Add subtle details, notes...',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _EnumDropdown<TaskPriority>(
                label: 'Priority',
                value: priority,
                values: TaskPriority.values,
                onChanged: onPriorityChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _EnumDropdown<Category>(
                label: 'Category',
                value: category,
                values: Category.values,
                onChanged: onCategoryChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EnumDropdown<T extends Enum> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> values;
  final ValueChanged<T> onChanged;

  const _EnumDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          items: values
              .map((v) => DropdownMenuItem(value: v, child: Text(v.label)))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }
}