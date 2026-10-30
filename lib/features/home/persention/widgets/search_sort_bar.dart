import 'package:flutter/material.dart';
import 'package:to_do_app/core/app_colors.dart';
import 'package:to_do_app/features/home/logic/home_cubit/home_cubit.dart';
import 'package:to_do_app/features/home/logic/home_cubit/home_states.dart';

class SearchSortBar extends StatefulWidget {
  final HomeState homeState;
  final HomeCubit homeCubit;

  const SearchSortBar({
    super.key,
    required this.homeState,
    required this.homeCubit,
  });

  @override
  State<SearchSortBar> createState() => _SearchSortBarState();
}

class _SearchSortBarState extends State<SearchSortBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // بنبدأ بقيمة البحث الحالية عشان لو الـ widget اتبنى من جديد النص ميضيعش.
    _controller = TextEditingController(text: widget.homeState.query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final homeState = widget.homeState;
    final homeCubit = widget.homeCubit;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            onChanged: homeCubit.changeSearch,
            decoration: InputDecoration(
              hintText: 'Search tasks',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: homeState.isSearching
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _controller.clear();
                        homeCubit.clearSearch();
                      },
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: homeCubit.toggleSortByPriority,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 48),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor:
                homeState.sortByPriority ? c.secondaryAccent : c.surface,
            foregroundColor:
                homeState.sortByPriority ? c.surface : c.textSecondary,
            side: BorderSide(color: c.border),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: const Text('Priority'),
        ),
      ],
    );
  }
}