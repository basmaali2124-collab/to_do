import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:to_do_app/core/app_colors.dart';
import 'package:to_do_app/core/theme_cubit.dart';

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
        Column(
          children: [
            Card(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 14, color: c.secondaryAccent),
                    const SizedBox(width: 8),
                    Text(DateFormat('MMM dd').format(DateTime.now())),
                    IconButton(
              tooltip: context.isDark ? 'Light mode' : 'Dark mode',
              onPressed: () => context
                  .read<ThemeCubit>()
                  .toggle(Theme.of(context).brightness),
              icon: Icon(
                context.isDark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                color: c.secondaryAccent,
              ),
            ),
                  ],
                ),
              ),
            ),
           
          ],
        ),
      ],
    );
  }
}