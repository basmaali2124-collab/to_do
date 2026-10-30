import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:to_do_app/core/app_colors.dart';
import 'package:to_do_app/core/task_model.dart';

extension EnumLabel on Enum {
  String get label => name[0].toUpperCase() + name.substring(1);
}

extension TaskPriorityStyle on TaskPriority {
  Color colorOf(BuildContext context) {
    switch (this) {
      case TaskPriority.high:
        return AppColors.destructive;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return context.colors.secondaryAccent;
    }
  }
}

extension CategoryStyle on Category {
  IconData get icon {
    switch (this) {
      case Category.work:
        return Icons.work_outline_rounded;
      case Category.personal:
        return Icons.person_outline_rounded;
      case Category.health:
        return Icons.favorite_border_rounded;
      case Category.home:
        return Icons.home_outlined;
      case Category.shopping:
        return Icons.shopping_bag_outlined;
      case Category.others:
        return Icons.label_outline_rounded;
    }
  }
}

extension TaskFormatting on TaskModel {
  String get dateLine {
    final day = DateFormat('dd MMM');
    final dayYear = DateFormat('dd MMM yyyy');
    final s = startAt;
    final e = endAt;

    if (s != null && e != null) {
      final sameDay = s.year == e.year && s.month == e.month && s.day == e.day;
      return sameDay
          ? dayYear.format(s)
          : '${day.format(s)} → ${dayYear.format(e)}';
    }
    return dayYear.format((s ?? e)!);
  }

  String get timeLine {
    final hour = DateFormat('hh:mm a');
    final s = startAt;
    final e = endAt;

    if (s != null && e != null) {
      return '${hour.format(s)} - ${hour.format(e)}';
    }
    return hour.format((s ?? e)!);
  }
}