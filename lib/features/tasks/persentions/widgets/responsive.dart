import 'package:flutter/material.dart';

class ResponsiveForm extends StatelessWidget {
  final Widget header;
  final List<Widget> firstColumn;
  final List<Widget> secondColumn;
  final List<Widget> actions;

  const ResponsiveForm({
    super.key,
    required this.header,
    required this.firstColumn,
    required this.secondColumn,
    required this.actions,
  });

  static const double _breakpoint = 600;
  static const double _maxWidth = 900;
  static const double _gap = 24;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= _breakpoint;

            if (!isWide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header,
                  const SizedBox(height: 16),
                  ...firstColumn,
                  const SizedBox(height: 16),
                  ...secondColumn,
                  const SizedBox(height: 36),
                  for (int i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(height: 16),
                    actions[i],
                  ],
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header,
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: firstColumn,
                      ),
                    ),
                    const SizedBox(width: _gap),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: secondColumn,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),
                Row(
                  children: [
                    for (int i = 0; i < actions.length; i++) ...[
                      if (i > 0) const SizedBox(width: _gap),
                      Expanded(child: actions[i]),
                    ],
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}