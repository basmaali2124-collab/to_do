import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:to_do_app/core/app_colors.dart';

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

  InputDecoration _decoration(
    BuildContext context, {
    required IconData icon,
    required bool hasError,
    required String errorText,
  }) {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      prefixIcon: Icon(
        icon,
        size: 18,
        color: hasError
            ? AppColors.destructive
            : context.colors.secondaryAccent,
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      errorText: hasError ? errorText : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 11,
          child: _LabeledField(
            label: 'Date',
            child: DateTimeFormField(
              initialValue: date,
              mode: DateTimeFieldPickerMode.date,
              dateFormat: DateFormat('dd MMM yyyy'),
              decoration: _decoration(
                context,
                icon: Icons.calendar_today_rounded,
                hasError: dateHasError,
                errorText: 'Invalid date',
              ),
              onChanged: (v) {
                if (v != null) onDateChanged(v);
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 10,
          child: _LabeledField(
            label: 'Time',
            child: DateTimeFormField(
              initialValue: time,
              mode: DateTimeFieldPickerMode.time,
              dateFormat: DateFormat('hh:mm a'),
              decoration: _decoration(
                context,
                icon: Icons.access_time_rounded,
                hasError: timeHasError,
                errorText: 'Invalid time',
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
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}