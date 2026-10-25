import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/core/app_colors.dart';
import 'package:to_do_app/core/app_typography.dart';
import 'package:to_do_app/core/validation_helper.dart';
import 'package:to_do_app/data/task_model.dart';
import 'package:to_do_app/logic/task_cubit/task_cubit.dart';
import 'package:to_do_app/presentation/task_operations/widgets/date_time_row.dart';
import 'package:to_do_app/presentation/task_operations/widgets/field_label.dart';
import 'package:to_do_app/presentation/task_operations/widgets/form_action_button.dart';
import 'package:to_do_app/presentation/task_operations/widgets/notification_card.dart';
import 'package:to_do_app/presentation/task_operations/widgets/task_app_bar.dart';

class AddTask extends StatefulWidget {
  const AddTask({super.key});
  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // الافتراضي: بعد ساعة من دلوقتي، عشان الـ Save بـ Title بس يشتغل
  final DateTime _defaultDateTime =
      DateTime.now().add(const Duration(hours: 1));
  late DateTime _selectedDate = _defaultDateTime;
  late DateTime _selectedTime = _defaultDateTime;

  DateTimeError _dateTimeError = DateTimeError.none;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final error = DateTimeValidator.check(_selectedDate, _selectedTime);
    if (error != DateTimeError.none) {
      setState(() => _dateTimeError = error);
      return;
    }

    context.read<TasksCubit>().addTask(
          TaskModel(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            date: _selectedDate,
            time: _selectedTime,
          ),
        );
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
              top: 28,
              left: 20,
              right: 20,
              bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "What's on your mind",
                    style: AppTypography.lightTextTheme.displayLarge,
                  ),
                  const SizedBox(height: 16),
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
                  const FieldLabel(
                    'Description',
                    suffix: '(Optional)',
                    suffixColor: AppColors.textSecondaryLight,
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
                  const SizedBox(height: 16),
                  DateTimeRow(
                    date: _selectedDate,
                    time: _selectedTime,
                    dateHasError: _dateTimeError == DateTimeError.pastDate,
                    timeHasError: _dateTimeError == DateTimeError.pastTime,
                    onDateChanged: (v) => setState(() {
                      _selectedDate = v;
                      _dateTimeError = DateTimeError.none;
                    }),
                    onTimeChanged: (v) => setState(() {
                      _selectedTime = v;
                      _dateTimeError = DateTimeError.none;
                    }),
                  ),
                  const SizedBox(height: 16),
                  const NotificationHintCard(),
                  const SizedBox(height: 36),
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