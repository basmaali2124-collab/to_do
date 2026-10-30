import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:to_do_app/core/app_colors.dart';

class FilterChipButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const FilterChipButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          side: BorderSide(color: c.border),
          minimumSize: Size(0, 40.h),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          backgroundColor: isSelected ? c.secondaryAccent : c.surface,
          foregroundColor: isSelected ? c.surface : c.textSecondary,
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}