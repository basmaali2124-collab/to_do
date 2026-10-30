import 'package:flutter/material.dart';
import 'package:to_do_app/core/app_colors.dart';
import 'package:to_do_app/core/validation_helper.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/date_time_row.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/field_label.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/section_card.dart';

class TaskScheduleCard extends StatelessWidget {
  final DateTime startDate;
  final DateTime startTime;
  final DateTime endDate;
  final DateTime endTime;
  final DateTimeError error;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onStartTimeChanged;
  final ValueChanged<DateTime> onEndDateChanged;
  final ValueChanged<DateTime> onEndTimeChanged;

  const TaskScheduleCard({
    super.key,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.error,
    required this.onStartDateChanged,
    required this.onStartTimeChanged,
    required this.onEndDateChanged,
    required this.onEndTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      children: [
        const FieldLabel('Start'),
        DateTimeRow(
          date: startDate,
          time: startTime,
          onDateChanged: onStartDateChanged,
          onTimeChanged: onStartTimeChanged,
        ),
        const SizedBox(height: 16),
        const FieldLabel('End'),
        DateTimeRow(
          date: endDate,
          time: endTime,
          dateHasError: error == DateTimeError.pastDate ||
              error == DateTimeError.invalidRange,
          timeHasError: error == DateTimeError.pastTime ||
              error == DateTimeError.invalidRange,
          onDateChanged: onEndDateChanged,
          onTimeChanged: onEndTimeChanged,
        ),
        if (error == DateTimeError.invalidRange)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'End must be after Start',
              style: TextStyle(color: AppColors.destructive, fontSize: 13),
            ),
          ),
      ],
    );
  }
}