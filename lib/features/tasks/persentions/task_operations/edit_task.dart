import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/core/app_colors.dart';
import 'package:to_do_app/core/validation_helper.dart';
import 'package:to_do_app/core/task_model.dart';
import 'package:to_do_app/features/tasks/logic/task_cubit/task_cubit.dart';
import 'package:to_do_app/features/tasks/persentions/task_operations/delete_task.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/form_action_button.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/notification_card.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/responsive.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/subtask_section.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/task_app_bar.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/task_info_card.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/task_schedule_card.dart';

class EditTask extends StatefulWidget {
  final TaskModel taskModel;
  const EditTask({super.key, required this.taskModel});

  @override
  State<EditTask> createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  final TextEditingController _subtaskController = TextEditingController();

  late DateTime _startDate;
  late DateTime _startTime;
  late DateTime _endDate;
  late DateTime _endTime;

  late TaskPriority _priority;
  late Category _category;
  late List<SubTask> _subtasks;

  bool _startChanged = false;
  bool _endChanged = false;
  DateTimeError _dateTimeError = DateTimeError.none;

  @override
  void initState() {
    super.initState();
    final task = widget.taskModel;

    _titleController = TextEditingController(text: task.title);
    _descriptionController =
        TextEditingController(text: task.description ?? '');

    final start = task.startAt ?? DateTime.now();
    final end = task.endAt ?? start.add(const Duration(hours: 1));

    _startDate = start;
    _startTime = start;
    _endDate = end;
    _endTime = end;

    _priority = task.priority;
    _category = task.category;
    _subtasks = List<SubTask>.from(task.subtasks);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  DateTime get _combinedStart => DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _startTime.hour,
        _startTime.minute,
      );

  DateTime get _combinedEnd => DateTime(
        _endDate.year,
        _endDate.month,
        _endDate.day,
        _endTime.hour,
        _endTime.minute,
      );

  void _addSubtask() {
    final text = _subtaskController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _subtasks.add(SubTask(title: text));
      _subtaskController.clear();
    });
  }

  void _removeSubtask(int index) {
    setState(() => _subtasks.removeAt(index));
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final error = context.read<TasksCubit>().submitUpdate(
          original: widget.taskModel,
          title: _titleController.text,
          description: _descriptionController.text,
          startAt: _combinedStart,
          endAt: _combinedEnd,
          dateTimeChanged: _startChanged || _endChanged,
          priority: _priority,
          category: _category,
          subtasks: _subtasks,
        );

    if (error != DateTimeError.none) {
      setState(() => _dateTimeError = error);
      return;
    }

    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const DeleteTask(),
    );
    if (confirmed == true && mounted) {
      context.read<TasksCubit>().deleteTask(widget.taskModel.id!);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: taskFormAppBar(context, 'Edit Task'),
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: EdgeInsets.only(
              top: 24,
              left: 20,
              right: 20,
              bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Form(
              key: _formKey,
              child: ResponsiveForm(
                header: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'Edit Task Details',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
                firstColumn: [
                  TaskInfoCard(
                    titleController: _titleController,
                    descriptionController: _descriptionController,
                    priority: _priority,
                    category: _category,
                    onPriorityChanged: (v) => setState(() => _priority = v),
                    onCategoryChanged: (v) => setState(() => _category = v),
                  ),
                  const SizedBox(height: 16),
                  SubtaskSection(
                    subtasks: _subtasks,
                    controller: _subtaskController,
                    onAdd: _addSubtask,
                    onRemove: _removeSubtask,
                  ),
                ],
                secondColumn: [
                  TaskScheduleCard(
                    startDate: _startDate,
                    startTime: _startTime,
                    endDate: _endDate,
                    endTime: _endTime,
                    error: _dateTimeError,
                    onStartDateChanged: (v) => setState(() {
                      _startDate = v;
                      _startChanged = true;
                      _dateTimeError = DateTimeError.none;
                    }),
                    onStartTimeChanged: (v) => setState(() {
                      _startTime = v;
                      _startChanged = true;
                      _dateTimeError = DateTimeError.none;
                    }),
                    onEndDateChanged: (v) => setState(() {
                      _endDate = v;
                      _endChanged = true;
                      _dateTimeError = DateTimeError.none;
                    }),
                    onEndTimeChanged: (v) => setState(() {
                      _endTime = v;
                      _endChanged = true;
                      _dateTimeError = DateTimeError.none;
                    }),
                  ),
                  const SizedBox(height: 16),
                  const NotificationHintCard(),
                ],
                actions: [
                  FormActionButton(
                    icon: Icons.check_rounded,
                    label: 'Save Changes',
                    onPressed: _save,
                  ),
                  FormActionButton(
                    icon: Icons.delete_outline_rounded,
                    label: 'Delete Task',
                    onPressed: _delete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.background,
                      foregroundColor: AppColors.destructive,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}