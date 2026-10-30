import 'package:flutter/material.dart';
import 'package:to_do_app/core/app_colors.dart';

class SectionCard extends StatelessWidget {
  final List<Widget> children;

  const SectionCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}