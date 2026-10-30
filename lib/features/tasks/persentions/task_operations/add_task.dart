import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/core/validation_helper.dart';
import 'package:to_do_app/core/task_model.dart';
import 'package:to_do_app/features/tasks/logic/task_cubit/task_cubit.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/form_action_button.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/notification_card.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/responsive.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/subtask_section.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/task_app_bar.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/task_info_card.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/task_schedule_card.dart';

class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _subtaskController = TextEditingController();

  final DateTime _now = DateTime.now();
  late DateTime _startDate = _now.add(const Duration(hours: 1));
  late DateTime _startTime = _now.add(const Duration(hours: 1));
  late DateTime _endDate = _now.add(const Duration(hours: 2));
  late DateTime _endTime = _now.add(const Duration(hours: 2));

  TaskPriority _priority = TaskPriority.low;
  Category _category = Category.others;
  final List<SubTask> _subtasks = [];

  DateTimeError _dateTimeError = DateTimeError.none;

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

    final error = context.read<TasksCubit>().submitTask(
          title: _titleController.text,
          description: _descriptionController.text,
          startAt: _combinedStart,
          endAt: _combinedEnd,
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: taskFormAppBar(context, 'New Task'),
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
                    "What's on your mind",
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
                      _dateTimeError = DateTimeError.none;
                    }),
                    onStartTimeChanged: (v) => setState(() {
                      _startTime = v;
                      _dateTimeError = DateTimeError.none;
                    }),
                    onEndDateChanged: (v) => setState(() {
                      _endDate = v;
                      _dateTimeError = DateTimeError.none;
                    }),
                    onEndTimeChanged: (v) => setState(() {
                      _endTime = v;
                      _dateTimeError = DateTimeError.none;
                    }),
                  ),
                  const SizedBox(height: 16),
                  const NotificationHintCard(),
                ],
                actions: [
                  FormActionButton(
                    icon: Icons.check_rounded,
                    label: 'Save Task',
                    onPressed: _save,
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