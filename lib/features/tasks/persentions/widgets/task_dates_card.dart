import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:to_do_app/core/app_colors.dart';
import 'package:to_do_app/features/tasks/persentions/widgets/section_card.dart';
class TaskDatesCard extends StatelessWidget {
  final DateTime? startAt;
  final DateTime? endAt;

  const TaskDatesCard({super.key, this.startAt, this.endAt});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy · hh:mm a');

    return SectionCard(
      children: [
        if (startAt != null)
          _InfoRow(
            icon: Icons.play_arrow_rounded,
            label: 'Start',
            value: fmt.format(startAt!),
          ),
        if (startAt != null && endAt != null) const SizedBox(height: 12),
        if (endAt != null)
          _InfoRow(
            icon: Icons.stop_rounded,
            label: 'End',
            value: fmt.format(endAt!),
          ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: c.secondaryAccent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: c.secondaryAccent),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(color: c.textSecondary),
            ),
            Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}