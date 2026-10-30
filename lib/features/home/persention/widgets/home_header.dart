import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/core/app_colors.dart';
import 'package:to_do_app/core/theme_cubit.dart';
import 'package:to_do_app/features/tasks/persentions/task_operations/add_task.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "A little progress every day",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: c.secondaryAccent,
                  height: 1.33,
                ),
              ),
              const SizedBox(height: 8),
              Text("My Tasks", style: Theme.of(context).textTheme.displayLarge),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Card(
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.read<ThemeCubit>().toggle(
                  Theme.of(context).brightness,
                ),
                icon: Icon(
                  context.isDark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  color: c.secondaryAccent,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddTask()),
                ),
                icon: Icon(Icons.add, size: 34, color: c.secondaryAccent),
              ),
            ],
          ),
        ),
      ],
    );
  }
}