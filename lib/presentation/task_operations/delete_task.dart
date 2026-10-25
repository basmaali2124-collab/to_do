import 'package:flutter/material.dart';
import 'package:to_do_app/core/app_colors.dart';
import 'package:to_do_app/core/app_typography.dart';

class DeleteTask extends StatelessWidget {
  const DeleteTask({super.key});
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.all(16),
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.destructiveBg,
          child: Icon(
            Icons.delete_outline_rounded,
            color: AppColors.destructive,
            size: 30,
          ),
        ),
        SizedBox(height: 12),
        Text(
          "Delete this task?",
          textAlign: TextAlign.center,
          style: AppTypography.lightTextTheme.displayLarge,
        ),
        SizedBox(height: 12),
        Text(
          "This task will be permanently removed.",
          textAlign: TextAlign.center,
          style: AppTypography.lightTextTheme.displayMedium,
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 45),
                  backgroundColor: AppColors.primaryAccentLight,
                  foregroundColor: AppColors.textMainLight,
                ),
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 50),
                  backgroundColor: AppColors.destructive,
                  foregroundColor: AppColors.surfaceLight,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Delete"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
