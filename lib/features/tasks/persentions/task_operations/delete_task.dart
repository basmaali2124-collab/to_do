import 'package:flutter/material.dart';
import 'package:to_do_app/core/app_colors.dart';

class DeleteTask extends StatelessWidget {
  const DeleteTask({super.key});
 static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const DeleteTask(),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return SimpleDialog(
      contentPadding: const EdgeInsets.all(16),
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: c.destructiveBg,
          child: const Icon(
            Icons.delete_outline_rounded,
            color: AppColors.destructive,
            size: 30,
          ),
        ),
        const SizedBox(height: 12),
        Text("Delete this task?",
            textAlign: TextAlign.center, style: textTheme.displayLarge),
        const SizedBox(height: 12),
        Text("This task will be permanently removed.",
            textAlign: TextAlign.center, style: textTheme.bodyMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 45),
                  backgroundColor: c.primaryAccent,
                  foregroundColor: c.textMain,
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
                  foregroundColor: Colors.white,
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