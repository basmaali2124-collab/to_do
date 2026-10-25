import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:to_do_app/core/app_colors.dart';
import 'package:to_do_app/core/app_typography.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "A little progress every day",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.secondaryAccentLight,
                height: 1.33,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "My Tasks",
              style: AppTypography.lightTextTheme.displayLarge,
            ),
          ],
        ),
        const Spacer(),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: AppColors.secondaryAccentLight,
                ),
                const SizedBox(width: 8),
                Text(DateFormat('MMM dd').format(DateTime.now())),
              ],
            ),
          ),
        ),
      ],
    );
  }
}