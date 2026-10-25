import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:to_do_app/core/app_colors.dart';
import 'package:to_do_app/core/app_typography.dart';

class ProgressCard extends StatelessWidget {
  final int completed;
  final int total;
  final double percent;

  const ProgressCard({
    super.key,
    required this.completed,
    required this.total,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: ListTile(
          leading: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(12),
            child: const Icon(CupertinoIcons.checkmark_square),
          ),
          title: Text(
            "$completed of $total completed",
            style: AppTypography.lightTextTheme.titleLarge,
          ),
          subtitle: Text(
            "keep going, you're doing great!",
            style: AppTypography.lightTextTheme.bodySmall,
          ),
          trailing: SizedBox(
            width: 50,
            height: 50,
            child: CircularPercentIndicator(
              radius: 25,
              percent: percent.clamp(0.0, 1.0),
              center: Text(
                "${(percent * 100).toInt()}%",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: AppColors.borderLight,
              progressColor: AppColors.secondaryAccentLight,
            ),
          ),
        ),
      ),
    );
  }
}