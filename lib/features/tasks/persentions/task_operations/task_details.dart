import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/core/app_colors.dart';
import 'package:to_do_app/core/extensions.dart';
import 'package:to_do_app/core/task_model.dart';
import 'package:to_do_app/core/widgets/app_pill.dart';
import 'package:to_do_app/features/tasks/logic/task_cubit/task_cubit.dart';
import 'package:to_do_app/features/tasks/logic/task_cubit/task_states.dart';
import 'package:to_do_app/features/tasks/persentions/task_operations/delete_task.dart';
import 'package:to_do_app/features/tasks/persentions/task_operations/edit_task.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/section_card.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/small_button.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/subtask_checklist_card.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/task_app_bar.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/task_dates_card.dart';

class TaskDetails extends StatefulWidget {
  final TaskModel task;
  const TaskDetails({super.key, required this.task});

  @override
  State<TaskDetails> createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> {
  // آخر نسخة معروفة من التاسك (بتفضل معروضة وإحنا بنقفل الصفحة بعد الحذف).
  late TaskModel _lastKnown = widget.task;
  bool _closing = false;

  TaskModel? _findTask(List<TaskModel> tasks) {
    for (final t in tasks) {
      if (t.id == widget.task.id) return t;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TasksCubit, TaskStates>(
      listenWhen: (_, current) => current is SuccessState,
      listener: (context, state) {
        if (state is! SuccessState) return;
        final found = _findTask(state.tasks);
        if (found != null) {
          _lastKnown = found;
        } else if (!_closing) { _closing = true;
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final task =
            state is SuccessState ? (_findTask(state.tasks) ?? _lastKnown) : _lastKnown;

        return Scaffold(
          appBar: taskFormAppBar(context, 'Task Details'),
          body: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
                  child: _buildBody(context, task),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, TaskModel task) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;

    final isDone = task.status == Status.completed;
    final isOverdue = task.isOverdue;
    final hasDescription =
        task.description != null && task.description!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                task.title,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  decorationColor: c.taskCompleted,
                  color: isDone ? c.taskCompleted : null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SmallButton(
                  icon: Icons.edit_outlined,
                  onPressed: () {context.toView(EditTask(taskModel: task));},
                ),
                SmallButton(
                  icon: Icons.delete_outline_rounded,
                  onPressed: () async {
                    final confirmed = await DeleteTask.show(context);
                    if (confirmed && context.mounted) {
                      context.read<TasksCubit>().deleteTask(task.id!);
                    }
                  },
                ),
                const SizedBox(width: 4),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            AppPill(
              icon: isDone
                  ? Icons.check_circle_rounded
                  : isOverdue
                      ? Icons.schedule_rounded
                      : Icons.hourglass_bottom_rounded,
              text: isDone
                  ? 'Completed'
                  : isOverdue
                      ? 'Overdue'
                      : 'Pending',
              color: isDone
                  ? c.secondaryAccent
                  : isOverdue
                      ? AppColors.destructive
                      : c.textSecondary,
            ),
            AppPill(
              icon: Icons.flag_rounded,
              text: task.priority.label,
              color: task.priority.colorOf(context),
            ),
            AppPill(
              icon: task.category.icon,
              text: task.category.label,
              color: c.secondaryAccent,
            ),
          ],
        ),
        const SizedBox(height: 20),
        SectionCard(
          children: [
            Text(
              'Description',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            if (hasDescription)
              Text(task.description!, style: textTheme.bodyMedium)
            else
              Text(
                'No description for this task.',
                style: textTheme.bodySmall?.copyWith(color: c.textSecondary),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (task.startAt != null || task.endAt != null) ...[
          TaskDatesCard(startAt: task.startAt, endAt: task.endAt),
          const SizedBox(height: 16),
        ],
        SubtasksChecklistCard(
          subtasks: task.subtasks,
          onToggle: (i) => context.read<TasksCubit>().toggleSubtask(task, i),
        ),
      ],
    );
  }
}