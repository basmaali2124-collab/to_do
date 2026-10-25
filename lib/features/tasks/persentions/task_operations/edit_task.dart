import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/core/app_colors.dart';
import 'package:to_do_app/core/validation_helper.dart';
import 'package:to_do_app/core/task_model.dart';
import 'package:to_do_app/features/tasks/logic/task_cubit/task_cubit.dart';
import 'package:to_do_app/features/tasks/persentions/task_operations/delete_task.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/date_time_row.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/field_label.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/form_action_button.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/notification_card.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/responsive.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/task_app_bar.dart';

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
  late DateTime _selectedDate;
  late DateTime _selectedTime;

  bool _dateChanged = false;
  bool _timeChanged = false;
  DateTimeError _dateTimeError = DateTimeError.none;

  @override
  void initState() {
    super.initState();
    final task = widget.taskModel;
    _titleController = TextEditingController(text: task.title);
    _descriptionController = TextEditingController(text: task.description);
    _selectedDate = task.date ?? DateTime.now();
    _selectedTime = task.time ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final error = context.read<TasksCubit>().submitUpdate(
          original: widget.taskModel,
          title: _titleController.text,
          description: _descriptionController.text,
          date: _selectedDate,
          time: _selectedTime,
          dateTimeChanged: _dateChanged || _timeChanged,
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
              top: 28,
              left: 20,
              right: 20,
              bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Form(
              key: _formKey,
              child: ResponsiveForm(
                header: Text(
                  'Edit Task Details',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                firstColumn: [
                  const FieldLabel(
                    'Task Title',
                    suffix: '*',
                    suffixColor: AppColors.destructive,
                  ),
                  TextFormField(
                    controller: _titleController,
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
                    controller: _descriptionController,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                    decoration: const InputDecoration(
                      hintText: 'Add subtle details, notes, or subtasks....',
                    ),
                  ),
                ],
                secondColumn: [
                  DateTimeRow(
                    date: _selectedDate,
                    time: _selectedTime,
                    dateHasError: _dateTimeError == DateTimeError.pastDate,
                    timeHasError: _dateTimeError == DateTimeError.pastTime,
                    onDateChanged: (v) => setState(() {
                      _selectedDate = v;
                      _dateChanged = true;
                      _dateTimeError = DateTimeError.none;
                    }),
                    onTimeChanged: (v) => setState(() {
                      _selectedTime = v;
                      _timeChanged = true;
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