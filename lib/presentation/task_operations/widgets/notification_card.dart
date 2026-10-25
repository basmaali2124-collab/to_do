import 'package:flutter/material.dart';
import 'package:to_do_app/core/app_colors.dart';
import 'package:to_do_app/core/app_typography.dart';

class NotificationHintCard extends StatelessWidget {
  const NotificationHintCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primaryAccentLight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.notifications_none,
              color: AppColors.secondaryAccentLight,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'A gentle notification will be scheduled for the selected date and time.',
                maxLines: 3,
                style: AppTypography.lightTextTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}