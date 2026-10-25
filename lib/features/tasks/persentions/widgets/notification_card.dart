import 'package:flutter/material.dart';
import 'package:to_do_app/core/app_colors.dart';

class NotificationHintCard extends StatelessWidget {
  const NotificationHintCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Card(
      color: c.primaryAccent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.notifications_none, color: c.secondaryAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'A gentle notification will be scheduled for the selected date and time.',
                maxLines: 3,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}