import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:to_do_app/core/app_colors.dart';
import 'package:to_do_app/features/home/logic/home_cubit/home_states.dart';

class EmptyContent {
  final String title;
  final String subtitle;
  final bool showAddButton;

  const EmptyContent({
    required this.title,
    required this.subtitle,
    this.showAddButton = false,
  });
}

extension EmptyTypeContent on EmptyType {
  EmptyContent get content {
    switch (this) {
      case EmptyType.noTasks:
        return const EmptyContent(
          title: "Nothing on your list yet",
          subtitle:
              "Enjoy your free time or capture a new item to keep your mind clear.",
          showAddButton: true,
        );
      case EmptyType.noResults:
        return const EmptyContent(
          title: "No results found",
          subtitle: "Try a different keyword or change the filter.",
        );
      case EmptyType.noPending:
        return const EmptyContent(
          title: "No pending tasks",
          subtitle: "Everything is done. Nice work!",
        );
      case EmptyType.noCompleted:
        return const EmptyContent(
          title: "No completed tasks yet",
          subtitle: "Finish a task and it will show up here.",
        );
      case EmptyType.emptyCategory:
        return const EmptyContent(
          title: "No results found",
          subtitle: "There are no tasks in this category yet",
        );
    }
  }
}

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
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(top: 40.h),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 60.h,
              backgroundColor: c.primaryAccent.withValues(alpha: 0.5),
              child: Icon(
                Icons.auto_awesome_outlined,
                size: 56,
                color: c.secondaryAccent,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: c.textSecondary),
              ),
            ),
            if (onAddPressed != null) ...[
              const SizedBox(height: 28),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(0, 56.h),
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  backgroundColor: c.primaryAccent,
                  foregroundColor: c.textMain,
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