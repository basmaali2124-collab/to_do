import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeRow extends StatelessWidget {
  final DateTime date;
  final DateTime time;
  final bool dateHasError;
  final bool timeHasError;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<DateTime> onTimeChanged;

  const DateTimeRow({
    super.key,
    required this.date,
    required this.time,
    required this.onDateChanged,
    required this.onTimeChanged,
    this.dateHasError = false,
    this.timeHasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _LabeledField(
            label: 'Date',
            child: DateTimeFormField(
              initialValue: date,
              mode: DateTimeFieldPickerMode.date,
              dateFormat: DateFormat('dd/MM/yyyy'),
              decoration: InputDecoration(
                errorText: dateHasError ? 'Invalid date' : null,
              ),
              onChanged: (v) {
                if (v != null) onDateChanged(v);
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _LabeledField(
            label: 'Time',
            child: DateTimeFormField(
              initialValue: time,
              mode: DateTimeFieldPickerMode.time,
              dateFormat: DateFormat('hh:mm a'),
              decoration: InputDecoration(
                errorText: timeHasError ? 'Invalid time' : null,
              ),
              onChanged: (v) {
                if (v != null) onTimeChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}