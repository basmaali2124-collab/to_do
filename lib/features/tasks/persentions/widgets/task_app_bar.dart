import 'package:flutter/material.dart';
import 'package:to_do_app/core/app_colors.dart';

AppBar taskFormAppBar(BuildContext context, String title) {
  final c = context.colors;
  return AppBar(
    leading: Padding(
      padding: const EdgeInsets.only(left: 14, top: 8, bottom: 8),
      child: IconButton(
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(26),
            side: BorderSide(color: c.border),
          ),
          backgroundColor: c.surface,
        ),
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
    ),
    centerTitle: true,
    title: Text(title),
  );
}