import 'package:flutter/material.dart';

class FormActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final ButtonStyle? style;

  const FormActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: style,
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(icon), Text(' $label')],
      ),
    );
  }
}