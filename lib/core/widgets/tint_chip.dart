import 'package:flutter/material.dart';
import 'package:to_do_app/core/app_colors.dart';

class TintChip extends StatelessWidget {
  final IconData icon;
  final String line1;
  final String? line2;
  final Color? color;

  const TintChip({
    super.key,
    required this.icon,
    required this.line1,
    this.line2,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? context.colors.secondaryAccent;
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: accent,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          height: 1.25,
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: accent),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(line1, style: style),
              if (line2 != null) Text(line2!, style: style),
            ],
          ),
        ],
      ),
    );
  }
}