import 'package:flutter/material.dart';
import 'package:to_do_app/core/app_colors.dart';
import 'package:to_do_app/core/app_typography.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onAddPressed;

  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primaryAccentLight.withValues(
                alpha: 0.5,
              ),
              child: const Icon(
                Icons.auto_awesome_outlined,
                size: 56,
                color: AppColors.secondaryAccentLight,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.lightTextTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTypography.lightTextTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ),
            if (onAddPressed != null) ...[
              const SizedBox(height: 28),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 56),
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  backgroundColor: AppColors.primaryAccentLight,
                  foregroundColor: AppColors.textMainLight,
                ),
                onPressed: onAddPressed,
                icon: const Icon(Icons.add),
                label: const Text("Add Your First Task"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}