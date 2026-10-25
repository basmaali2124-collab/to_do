import 'package:flutter/material.dart';
import 'package:to_do_app/core/app_colors.dart';

class StatusButton extends StatelessWidget {
  final String name;
  final int num;
  final bool isSelected;
  final VoidCallback onPressed;

  const StatusButton({
    super.key,
    required this.name,
    required this.num,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          side: const BorderSide(color: AppColors.borderLight),
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          backgroundColor: isSelected
              ? AppColors.secondaryAccentLight
              : AppColors.surfaceLight,
          foregroundColor: isSelected
              ? AppColors.surfaceLight
              : AppColors.textSecondaryLight,
        ),
        onPressed: onPressed,
        child: Text("$name  ($num)"),
      ),
    );
  }
}