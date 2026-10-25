import 'package:flutter/material.dart';

class FieldLabel extends StatelessWidget {
  final String label;
  final String? suffix;
  final Color? suffixColor;

  const FieldLabel(this.label, {super.key, this.suffix, this.suffixColor});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: '$label ',
        children: [
          if (suffix != null)
            TextSpan(text: suffix, style: TextStyle(color: suffixColor)),
        ],
      ),
    );
  }
}