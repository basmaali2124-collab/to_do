import 'package:flutter/material.dart';

abstract class AppColors {
  // Light Theme Palette
  static const Color backgroundLight = Color(0xFFF7F8FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color primaryAccentLight = Color(0xFFD7E5F2);
  static const Color secondaryAccentLight = Color(0xFF91B6D5);
  static const Color textMainLight = Color(0xFF344B66);
  static const Color textSecondaryLight = Color(0xFF858B94);
  static const Color taskCompletedLight = Color(0xFFB2C5D6);
  static const Color borderLight = Color(0xFFE5EBF0);
  static const Color destructiveBgLight = Color(0xFFFDF2F2);

  // Dark Theme Palette
  static const Color backgroundDark = Color(0xFF1A232E);
  static const Color surfaceDark = Color(0xFF24303E);
  static const Color primaryAccentDark = Color(0xFF2C4257);
  static const Color secondaryAccentDark = Color(0xFFA1C4E2);
  static const Color textMainDark = Color(0xFFE8EEF5);
  static const Color textSecondaryDark = Color(0xFF9AA7B5);
  static const Color taskCompletedDark = Color(0xFF5F7389);
  static const Color borderDark = Color(0xFF324356);
  static const Color destructiveBgDark = Color(0xFF3A2528);

  // Destructive Actions
  static const Color destructive = Color(0xFFE57373);
  static const Color destructiveBg = destructiveBgLight; // للتوافق مع القديم
}

/// مجموعة ألوان واحدة بتتغير حسب الوضع (Light / Dark)
class AppPalette {
  final Color background;
  final Color surface;
  final Color primaryAccent;
  final Color secondaryAccent;
  final Color textMain;
  final Color textSecondary;
  final Color taskCompleted;
  final Color border;
  final Color destructiveBg;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.primaryAccent,
    required this.secondaryAccent,
    required this.textMain,
    required this.textSecondary,
    required this.taskCompleted,
    required this.border,
    required this.destructiveBg,
  });

  static const light = AppPalette(
    background: AppColors.backgroundLight,
    surface: AppColors.surfaceLight,
    primaryAccent: AppColors.primaryAccentLight,
    secondaryAccent: AppColors.secondaryAccentLight,
    textMain: AppColors.textMainLight,
    textSecondary: AppColors.textSecondaryLight,
    taskCompleted: AppColors.taskCompletedLight,
    border: AppColors.borderLight,
    destructiveBg: AppColors.destructiveBgLight,
  );

  static const dark = AppPalette(
    background: AppColors.backgroundDark,
    surface: AppColors.surfaceDark,
    primaryAccent: AppColors.primaryAccentDark,
    secondaryAccent: AppColors.secondaryAccentDark,
    textMain: AppColors.textMainDark,
    textSecondary: AppColors.textSecondaryDark,
    taskCompleted: AppColors.taskCompletedDark,
    border: AppColors.borderDark,
    destructiveBg: AppColors.destructiveBgDark,
  );
}

extension AppThemeContext on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  AppPalette get colors => isDark ? AppPalette.dark : AppPalette.light;
}