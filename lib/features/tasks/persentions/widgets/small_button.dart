import 'package:flutter/material.dart';
import 'package:to_do_app/core/app_colors.dart';

class SmallButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const SmallButton({super.key, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      iconSize: 22,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
      icon: Icon(icon, color: context.colors.secondaryAccent),
    );
  }
}