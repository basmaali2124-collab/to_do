import 'package:flutter/material.dart';
import 'package:to_do_app/core/task_model.dart';
import 'package:to_do_app/features/tasks/persentions/task_operations/task_form.dart';

class EditTask extends StatelessWidget {
  final TaskModel taskModel;
  const EditTask({super.key, required this.taskModel});

  @override
  Widget build(BuildContext context) => TaskForm(task: taskModel);
}