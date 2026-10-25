import 'package:flutter/material.dart';
import 'package:to_do_app/core/app_colors.dart';

/// AppBar مشترك بين شاشتي Add و Edit (زرار رجوع + عنوان في النص).
AppBar taskFormAppBar(BuildContext context, String title) {
  return AppBar(
    leading: Padding(
      padding: const EdgeInsets.only(left: 14, top: 8, bottom: 8),
      child: IconButton(
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(26),
            side: const BorderSide(color: AppColors.borderLight),
          ),
          backgroundColor: AppColors.surfaceLight,
        ),
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
    ),
    centerTitle: true,
    title: Text(title),
  );
}