import 'package:flutter/material.dart';
import 'package:to_do_app/features/home/logic/home_cubit/home_cubit.dart';
import 'package:to_do_app/features/home/logic/home_cubit/home_states.dart';
import 'package:to_do_app/features/home/persention/widgets/filter_chip_button.dart';
import 'package:to_do_app/features/tasks/logic/task_cubit/task_states.dart';

class StatusFilter extends StatelessWidget {
  const StatusFilter({
    super.key,
    required this.success,
    required this.filter,
    required this.homeCubit,
  });

  final SuccessState success;
  final StatusFilterType filter;
  final HomeCubit homeCubit;

  @override
  Widget build(BuildContext context) {
    final items = <(StatusFilterType, String, int)>[
      (StatusFilterType.all, 'All', success.total),
      (StatusFilterType.pending, 'Pending', success.pendingCount),
      (StatusFilterType.completed, 'Completed', success.completedCount),
    ];

    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final (type, name, count) in items)
            FilterChipButton(
              label: '$name  ($count)',
              isSelected: filter == type,
              onPressed: () => homeCubit.changeFilter(type),
            ),
        ],
      ),
    );
  }
}