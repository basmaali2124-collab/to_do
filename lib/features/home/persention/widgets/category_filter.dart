import 'package:flutter/material.dart';
import 'package:to_do_app/core/extensions.dart';
import 'package:to_do_app/features/home/logic/home_cubit/home_cubit.dart';
import 'package:to_do_app/features/home/logic/home_cubit/home_states.dart';
import 'package:to_do_app/features/home/persention/widgets/filter_chip_button.dart';
import 'package:to_do_app/features/tasks/logic/task_cubit/task_states.dart';

class CategoryFilter extends StatelessWidget {
  const CategoryFilter({
    super.key,
    required this.success,
    required this.categoryFilter,
    required this.homeCubit,
  });

  final SuccessState success;
  final CategoryFilterType categoryFilter;
  final HomeCubit homeCubit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final type in CategoryFilterType.values)
            FilterChipButton(
              label: type == CategoryFilterType.all ? 'All categories' : type.label,
              isSelected: categoryFilter == type,
              onPressed: () => homeCubit.changeCategoryFilter(type),
            ),
        ],
      ),
    );
  }
}