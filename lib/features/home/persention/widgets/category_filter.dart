import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/core/extensions.dart';
import 'package:to_do_app/features/home/logic/home_cubit/home_cubit.dart';
import 'package:to_do_app/features/home/logic/home_cubit/home_states.dart';
import 'package:to_do_app/features/home/persention/widgets/filter_chip_button.dart';

class CategoryFilter extends StatelessWidget {
  const CategoryFilter({super.key, required this.categoryFilter});

  final CategoryFilterType categoryFilter;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final type in CategoryFilterType.values)
            FilterChipButton(
              label: type == CategoryFilterType.all
                  ? 'All categories'
                  : type.label,
              isSelected: categoryFilter == type,
              onPressed: () =>
                  context.read<HomeCubit>().changeCategoryFilter(type),
            ),
        ],
      ),
    );
  }
}